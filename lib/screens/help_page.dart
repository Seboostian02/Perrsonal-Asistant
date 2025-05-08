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
                    "Ajutor si Suport",
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
                        "Bine ai venit in sectiunea de Ajutor si Suport. Aici poti gasi informatii despre utilizarea aplicatiei, intrebari frecvente si modalitati de a contacta echipa noastra de suport.",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        "Intrebari frecvente:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "1. Cum pot accesa calendarul in aplicatie?\n   - Dupa autentificare, poti accesa calendarul din pagina principala.\n\n2. Ce trebuie sa fac daca nu primesc notificari pentru evenimente?\n   - Verifica permisiunile de notificare din setarile dispozitivului tau.\n\n3. Cum pot contacta echipa de suport daca intampin o problema?\n   - Poti trimite un email la ${ContactData.email}.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        "Metode de contact:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "- Email: ${ContactData.email}\n- Suport in aplicatie: Trimite-ne feedback din setarile aplicatiei.\n- Telefon: ${ContactData.phone}",
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
