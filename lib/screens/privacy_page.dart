import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
                  "Politica de Confidențialitate",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ultima actualizare: Decembrie 2023",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Text(
                  "1. **Colectarea datelor:**\nAplicația colectează informații limitate, cum ar fi datele de locație și notificări, pentru a funcționa optim.\n\n2. **Utilizarea datelor:**\nInformațiile sunt utilizate doar pentru scopurile menționate, cum ar fi planificarea calendarului și alertele bazate pe locație.\n\n3. **Protejarea datelor:**\nInformațiile sunt criptate și protejate conform standardelor de securitate moderne.\n\n4. **Partajarea datelor:**\nNu partajăm informațiile personale cu terțe părți fără acordul explicit al utilizatorului.\n\n5. **Contact:**\nDacă ai întrebări sau preocupări cu privire la politica noastră de confidențialitate, te poți adresa echipei noastre la contact@myapp.com.",
                  style: TextStyle(fontSize: 16),
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
