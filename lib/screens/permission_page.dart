import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    final locationPermission = await Permission.location.request();
    final notificationPermission = await Permission.notification.request();
    final exactAlarmPermission = await Permission.scheduleExactAlarm.request();

    if (locationPermission.isGranted &&
        notificationPermission.isGranted &&
        exactAlarmPermission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All permissions granted!')),
      );
      // Navighează mai departe dacă este necesar
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      // Unele permisiuni nu au fost acordate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Some permissions were denied. Please grant all permissions for full functionality.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This app needs location, notification, and exact alarm permissions to function properly.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _requestPermissions(context),
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
