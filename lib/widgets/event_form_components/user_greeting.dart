import 'package:calendar/services/auth_provider.dart';
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
              "Time to schedule something important, ${authProvider.currentUser?.displayName ?? ''}! ",
              textAlign: TextAlign.center,
            )
          : ElevatedButton(
              onPressed: authProvider.signInWithGoogle,
              child: const Text('Log In with Google'),
            ),
    );
  }
}
