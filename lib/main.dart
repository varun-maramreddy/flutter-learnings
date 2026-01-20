import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learnings/views/login_view.dart';
import 'package:flutter_learnings/views/register_view.dart';
import 'package:flutter_learnings/views/verify_email_view.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/verify-email/': (context) => const VerifyEmailView(),
        '/dashboard/': (context) => const Dashboard(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).then((value) => ("Firebase Initialized...")),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              print("Current User: $user");
              final emailVerified = user?.emailVerified ?? false;
              if(user == null) {
                print("User not logged in");
                return const LoginView();
              } else if(emailVerified) {
                print("You are logged in and email is verified");
                return const Dashboard();
                // return const LoginView();
              } else {
                print("You need to verify your email first");
                return const VerifyEmailView();
              }
              return Center(child: Text("Firebase Initialized Successfully!"));
            default:
              return Scaffold(
                body: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...'),
                    ],
                  ),
                ),
              );
          }
        },
      );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.green[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Dashboard'),
      ),
    );
  }
}
