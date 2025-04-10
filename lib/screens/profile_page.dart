import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For accessing AuthProvider

import '../services/auth_provider.dart'; // Import the AuthProvider
import '../utils/colors.dart'; // Import the AppColors class

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accessing the AuthProvider to get current user's details
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // Check if user is logged in
    if (currentUser == null) {
      return const Center(child: Text("Utilizatorul nu este autentificat."));
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(currentUser.photoURL ??
                  'https://www.example.com/default_avatar.png'), // Use user's photo URL or a default image
            ),
            const SizedBox(height: 20),
            // User's Name
            Text(
              currentUser.displayName ?? 'No Name Provided',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            // User's Email
            Text(
              currentUser.email ?? 'No Email Provided',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryColor,
              ),
            ),
            const SizedBox(height: 30),

            // Profile Settings Section (Account Settings)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              color: AppColors.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Setari cont',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.security, color: AppColors.secondaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Schimba parola',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.dividerColor),
                    Row(
                      children: [
                        Icon(Icons.notifications,
                            color: AppColors.secondaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Preferinte notificari',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Divider(color: AppColors.dividerColor),
                    Row(
                      children: [
                        Icon(Icons.language, color: AppColors.secondaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Preferinte limba',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
