import 'package:TimeBuddy/screens/help_page.dart';
import 'package:TimeBuddy/screens/notifications_page.dart';
import 'package:TimeBuddy/screens/privacy_page.dart';
import 'package:TimeBuddy/screens/profile_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_provider.dart';

class SettingsList extends StatelessWidget {
  final AuthProvider authProvider;

  const SettingsList({Key? key, required this.authProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  child: const ProfilePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  child: const NotificationsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  child: const PrivacyPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  child: const HelpSupportPage(),
                ),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 20),
          if (authProvider.isLoggedIn)
            ElevatedButton(
              onPressed: authProvider.signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              child:
                  const Text('Log Out', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
