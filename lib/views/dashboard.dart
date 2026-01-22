import 'package:flutter/material.dart';
import 'package:flutter_learnings/constants/routes.dart';
import 'package:flutter_learnings/enum/menu_action.dart';
import 'package:flutter_learnings/services/auth/auth_exceptions.dart';
import 'package:flutter_learnings/services/auth/auth_service.dart';
import 'package:flutter_learnings/utils/show_error_snackbar.dart';
import 'package:flutter_learnings/utils/show_logout_dialog.dart';
import 'package:flutter_learnings/views/notes/notes.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green[300],
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    try {
                      await AuthService.firebase().logOut();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    } on UserNotFoundAuthException {
                      showErrorSnackBar(context, 'User not found');
                    } catch (error) {
                      showErrorSnackBar(context, 'Error during logout: $error');
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 20, color: Colors.redAccent),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: const Center(child: NotesView()),
    );
  }
}
