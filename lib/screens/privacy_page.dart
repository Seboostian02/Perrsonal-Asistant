import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:TimeBuddy/utils/contact.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
                    "Politica de Confidentialitate",
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
                        "Ultima actualizare: Decembrie 2023",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "1. **Colectarea datelor:**\nAplicatia colecteaza informatii limitate precum date despre locatie si notificari pentru a functiona optim.\n\n"
                        "2. **Utilizarea datelor:**\nInformatiile sunt folosite exclusiv in scopurile mentionate, precum planificarea calendarului si alertele bazate pe locatie.\n\n"
                        "3. **Protectia datelor:**\nInformatiile sunt criptate si protejate conform standardelor moderne de securitate.\n\n"
                        "4. **Partajarea datelor:**\nNu partajam informatii personale cu terti fara consimtamantul expres al utilizatorului.\n\n"
                        "5. **Contact:**\nDaca ai intrebari sau nelamuriri legate de politica noastra de confidentialitate, ne poti contacta la ${ContactData.email}.",
                        style: TextStyle(fontSize: 16),
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
