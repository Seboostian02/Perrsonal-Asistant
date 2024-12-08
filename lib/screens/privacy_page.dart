import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:TimeBuddy/utils/contact.dart';

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
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Last updated: December 2023",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Text(
                  "1. **Data Collection:**\nThe app collects limited information such as location data and notifications to function optimally.\n\n2. **Use of Data:**\nThe information is used solely for the purposes mentioned, such as calendar planning and location-based alerts.\n\n3. **Data Protection:**\nInformation is encrypted and secured according to modern security standards.\n\n4. **Data Sharing:**\nWe do not share personal information with third parties without the user's explicit consent.\n\n5. **Contact:**\nIf you have any questions or concerns regarding our privacy policy, you can contact our team at ${ContactData.email}.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Go Back"),
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
