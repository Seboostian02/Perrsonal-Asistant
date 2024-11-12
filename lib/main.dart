import 'package:calendar/services/auth_service.dart';
import 'package:calendar/services/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:provider/provider.dart';
import 'screens/main_page.dart';
import 'screens/login_page.dart';
import 'services/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:calendar/services/google_calendar_service.dart';
import 'package:calendar/services/notification_service.dart'; // Import NotificationService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final hasPermission = await _checkLocationPermission();
  final hasNotificationPermission = await _checkNotificationPermission();
  final hasExactAlarmPermission = await _checkExactAlarmPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(
        hasLocationPermission: hasPermission,
        hasNotificationPermission: hasNotificationPermission,
        hasExactAlarmPermission: hasExactAlarmPermission,
      ),
    ),
  );
}

Future<bool> _checkLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied) {
    await Permission.location.request();
    status = await Permission.location.status;
  }
  return status.isGranted;
}

Future<bool> _checkNotificationPermission() async {
  var status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
    status = await Permission.notification.status;
  }
  return status.isGranted;
}

Future<bool> _checkExactAlarmPermission() async {
  if (await Permission.notification.isGranted) {
    return true;
  }
  var status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
    status = await Permission.notification.status;
  }
  return status.isGranted;
}

class MyApp extends StatelessWidget {
  final bool hasLocationPermission;
  final bool hasNotificationPermission;
  final bool hasExactAlarmPermission;

  const MyApp({
    super.key,
    required this.hasLocationPermission,
    required this.hasNotificationPermission,
    required this.hasExactAlarmPermission,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;

    return MaterialApp(
      home: hasLocationPermission && hasExactAlarmPermission
          ? (isLoggedIn ? const MainPage() : const LoginPage())
          : const PermissionPage(),
    );
  }
}

class PermissionPage extends StatelessWidget {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'This app needs location and notification permissions to function properly.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final hasLocation = await _checkLocationPermission();
                final hasNotification = await _checkNotificationPermission();
                final hasExactAlarm = await _checkExactAlarmPermission();

                if (hasLocation && hasNotification && hasExactAlarm) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyApp(
                              hasLocationPermission: true,
                              hasNotificationPermission: true,
                              hasExactAlarmPermission: true,
                            )),
                  );
                }
              },
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
