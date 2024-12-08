import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Ajutor și Suport",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Bine ai venit în secțiunea Ajutor și Suport. Aici poți găsi informații despre utilizarea aplicației, întrebări frecvente și modalități de a contacta echipa noastră.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Întrebări frecvente:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "1. Cum pot accesa calendarul din aplicație?\n   - După autentificare, vei avea acces la calendar din pagina principală.\n\n2. Ce să fac dacă nu primesc alerte despre evenimente?\n   - Verifică permisiunile de notificare din setările dispozitivului.\n\n3. Cum pot contacta echipa de suport dacă întâmpin o problemă?\n   - Poți trimite un e-mail la adresa contact@myapp.com.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  "Modalități de contact:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "- Email: contact@myapp.com\n- Suport prin aplicație: Trimite-ne feedback din setările aplicației.\n- Telefon: +40 123 456 7890",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Înapoi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: AppColors.textColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
