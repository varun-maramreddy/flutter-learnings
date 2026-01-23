import 'package:flutter/foundation.dart';
import 'package:flutter_learnings/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final lowerCaseEmail = email.toLowerCase();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [lowerCaseEmail],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final lowerCaseEmail = email.toLowerCase();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email= ?',
      whereArgs: [lowerCaseEmail],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }
    final userId = await db.insert(userTable, {emailColumn: lowerCaseEmail});
    return DatabaseUser(id: userId, email: lowerCaseEmail);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: '$emailColumn = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      noteTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return DatabaseNote.fromRow(results.first);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(noteTable);
    return results.map((row) => DatabaseNote.fromRow(row)).toList();
  }

  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    required String title,
    required String note,
  }) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      noteColumn: note,
    });
    return DatabaseNote(id: noteId, userId: owner.id, title: title, note: note);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String title,
    required String content,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatedCount = await db.update(
      noteTable,
      {titleColumn: title, noteColumn: content},
      where: '$idColumn = ?',
      whereArgs: [note.id],
    );
    if (updatedCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseAlreadyOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseAlreadyOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create user table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $userTable (
          $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
          $emailColumn TEXT NOT NULL UNIQUE
        )
      ''');

      // Create note table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $noteTable (
          $idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
          $userIdColumn INTEGER NOT NULL,
          $titleColumn TEXT NOT NULL,
          $noteColumn TEXT NOT NULL,
          FOREIGN KEY ($userIdColumn) REFERENCES $userTable($idColumn)
        )
      ''');
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    } catch (e) {
      rethrow;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String title;
  final String note;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.note,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      title = map[titleColumn] as String,
      note = map[noteColumn] as String;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, title = $title, note = $note';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const titleColumn = 'title';
const noteColumn = 'note';
