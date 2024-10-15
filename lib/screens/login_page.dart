import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
              'https://www.googleapis.com/auth/calendar',
            ]);

            await googleSignIn.signOut();

            authProvider.signInWithGoogle();
          },
          child: const Text("Login with Google"),
        ),
      ),
    );
  }
}
