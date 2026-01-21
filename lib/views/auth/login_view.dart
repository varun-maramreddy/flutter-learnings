import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learnings/constants/routes.dart';
import 'package:flutter_learnings/utils/show_error_snackbar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                    print("User Logged In: $userCredential");
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(dashboardRoute, (route) => false);
                  } on FirebaseAuthException catch (e) {
                    print("Error Code: ${e.code}");
                    if (e.code == 'user-not-found') {
                      showErrorSnackBar(context, 'User not found');
                      print("User not found");
                    } else if (e.code == 'wrong-password') {
                      showErrorSnackBar(context, 'Wrong password provided');
                      print("Wrong password provided");
                    } else {
                      showErrorSnackBar(
                        context,
                        'Authentication error: ${e.code}',
                      );
                      print('FirebaseAuthException: $e');
                    }
                  } catch (e) {
                    showErrorSnackBar(context, 'Something went wrong: $e');
                    print('Something went wrong: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // removes button padding
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Not registered yet? Register here!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
