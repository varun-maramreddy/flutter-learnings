import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learnings/firebase_options.dart';
import 'package:flutter_learnings/utils/show_error_snackbar.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.green[300],
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text('Please verify your email address.'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
              child: const Text(
                            'Send Verification Email',
                            style: TextStyle(fontSize: 16),
                          ),
            ),
          ],
        ),
    );
  }
}