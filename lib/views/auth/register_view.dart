import 'dart:developer' as devtools;
import 'package:flutter/material.dart';
import 'package:flutter_learnings/constants/routes.dart';
import 'package:flutter_learnings/services/auth/auth_exceptions.dart';
import 'package:flutter_learnings/services/auth/auth_service.dart';
import 'package:flutter_learnings/utils/show_error_snackbar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.green[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  print("Button Pressed");

                  final email = _email.text;
                  final password = _password.text;

                  try {
                    final userCredential = await AuthService.firebase()
                        .createUser(email: email, password: password);
                    devtools.log("User Created: $userCredential");
                    try {
                      await AuthService.firebase().sendEmailVerification();
                    } catch (e) {
                      showErrorSnackBar(
                        context,
                        'Error sending verification email: $e',
                      );
                      debugPrint('Failed to send verification email: $e');
                    }
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordAuthException {
                    showErrorSnackBar(
                      context,
                      'The password provided is too weak.',
                    );
                    devtools.log('The password provided is too weak.');
                  } on EmailAlreadyInUseAuthException {
                    showErrorSnackBar(
                      context,
                      'The account already exists for that email.',
                    );
                    devtools.log('The account already exists for that email.');
                  } on InvalidEmailAuthException {
                    showErrorSnackBar(
                      context,
                      'The email address is not valid.',
                    );
                    devtools.log('The email address is not valid.');
                  } on GenericAuthException {
                    showErrorSnackBar(context, 'Registration error occurred.');
                    devtools.log('Registration error occurred.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // removes button padding
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Already registered? Login here!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
