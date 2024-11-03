import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  final VoidCallback onBackToHome;

  const NotFoundPage({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page Not Found"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            onBackToHome();
          },
          child: const Text("Go Back to Home"),
        ),
      ),
    );
  }
}
