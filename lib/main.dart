import 'package:calendar/screens/permission_page.dart';
import 'package:calendar/services/event_provider.dart';
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
  if (await Permission.scheduleExactAlarm.isGranted) {
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
      home: hasLocationPermission && hasExactAlarmPermission
          ? (isLoggedIn ? const MainPage() : const LoginPage())
          : const PermissionPage(),
    );
  }
}
