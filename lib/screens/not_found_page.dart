import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  final VoidCallback
      onBackToHome; // Callback pentru a reveni la pagina principală

  const NotFoundPage(
      {super.key, required this.onBackToHome}); // Adaugă parametrul

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
