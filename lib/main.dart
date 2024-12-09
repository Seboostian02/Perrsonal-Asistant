import 'package:TimeBuddy/services/event_provider.dart';
import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_page.dart';
import 'screens/login_page.dart';
import 'services/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/google_calendar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));
  final hasPermission = await _checkLocationPermission();
  final hasNotificationPermission = await _checkNotificationPermission();
  final hasExactAlarmPermission = await _checkExactAlarmPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoogleCalendarService.instance),
      ],
      child: MyApp(
        hasLocationPermission: hasPermission,
        hasNotificationPermission: hasNotificationPermission,
        hasExactAlarmPermission: hasExactAlarmPermission,
      ),
    ),
  );
}

Future<bool> _requestPermission(Permission permission) async {
  var status = await permission.status;

  if (status.isDenied || status.isRestricted) {
    // Cere permisiunea
    status = await permission.request();
  }

  if (status.isPermanentlyDenied) {
    // Arată utilizatorului un dialog pentru a accesa setările aplicației
    await openAppSettings();
    status = await permission.status;
  }

  return status.isGranted;
}

Future<bool> _checkLocationPermission() async {
  return _requestPermission(Permission.location);
}

Future<bool> _checkNotificationPermission() async {
  return _requestPermission(Permission.notification);
}

Future<bool> _checkExactAlarmPermission() async {
  if (await Permission.notification.isGranted) {
    return true;
  }
  return _requestPermission(Permission.scheduleExactAlarm);
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
      debugShowCheckedModeBanner: false,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLightColor,
              AppColors.primaryDarkColor,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 100,
                  color: AppColors.iconColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Permissions Required",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "To continue, please grant the required permissions.",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () async {
                    final hasLocation = await _checkLocationPermission();
                    final hasNotification =
                        await _checkNotificationPermission();
                    final hasExactAlarm = await _checkExactAlarmPermission();

                    if (hasLocation && hasNotification && hasExactAlarm) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyApp(
                            hasLocationPermission: true,
                            hasNotificationPermission: true,
                            hasExactAlarmPermission: true,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Grant Permissions"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: AppColors.textColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Permissions needed: Location, Notifications, and Exact Alarms.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColor.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
