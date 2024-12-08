import 'package:TimeBuddy/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserGreeting extends StatelessWidget {
  const UserGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Center(
      child: authProvider.isLoggedIn
          ? Text(
              "On your way to be more organized, ${authProvider.currentUser?.displayName ?? ''}! ",
              textAlign: TextAlign.center,
            )
          : ElevatedButton(
              onPressed: authProvider.signInWithGoogle,
              child: const Text('Log In with Google'),
            ),
    );
  }
}
