import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleLogin(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException code: ${e.code}');
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password';
        } else if (e.code == 'invalid-credential') {
          // Could be wrong password or non-existing email, but we can't distinguish
          message = 'Incorrect email or password';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email address';
        } else {
          message = 'Login failed: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '* Email is required';
                }
                // Simple email regex
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value)) {
                  return '* Enter a valid email address';
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '* Password is required';
                } else if (value.length < 6) {
                  return '* Min 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => handleLogin(context),
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              child: Text('Don\'t have an account? Register'),
            )
          ]),
        ),
      ),
    );
  }
}
