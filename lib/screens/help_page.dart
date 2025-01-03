import 'package:TimeBuddy/utils/colors.dart';
import 'package:TimeBuddy/utils/contact.dart';
import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    iconSize: 30,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Help and Support",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome to the Help and Support section. Here you can find information on how to use the app, frequently asked questions, and ways to contact our support team.",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        "Frequently Asked Questions:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "1. How can I access my calendar in the app?\n   - After signing in, you can access the calendar from the home page.\n\n2. What should I do if I am not receiving event alerts?\n   - Check the notification permissions in your device settings.\n\n3. How can I contact the support team if I encounter a problem?\n   - You can send an email to ${ContactData.email}.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        "Contact Methods:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "- Email: ${ContactData.email}\n- In-app support: Send us feedback through the app settings.\n- Phone: ${ContactData.phone}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
