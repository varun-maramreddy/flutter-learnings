import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learnings/constants/routes.dart';
import 'package:flutter_learnings/views/dashboard.dart';
import 'package:flutter_learnings/views/auth/login_view.dart';
import 'package:flutter_learnings/views/auth/register_view.dart';
import 'package:flutter_learnings/views/auth/verify_email_view.dart';
import 'firebase_options.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        dashboardRoute: (context) => const Dashboard(),
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
            if (user == null) {
              print("User not logged in");
              return const LoginView();
            } else if (emailVerified) {
              devtools.log("You are logged in and email is verified");
              print("You are logged in and email is verified");
              return const Dashboard();
              // return const LoginView();
            } else {
              print("You need to verify your email first");
              return const VerifyEmailView();
            }
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
