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
import 'package:calendar/services/google_calendar_service.dart'; // Importă GoogleCalendarService

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
    return MaterialApp(
      home: hasLocationPermission && hasExactAlarmPermission
          ? (Provider.of<AuthProvider>(context).isLoggedIn
              ? const MainPage()
              : const LoginPage())
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
              onPressed: () {
                _checkLocationPermission().then((hasLocationPermission) {
                  _checkNotificationPermission()
                      .then((hasNotificationPermission) {
                    _checkExactAlarmPermission()
                        .then((hasExactAlarmPermission) {
                      if (hasLocationPermission &&
                          hasNotificationPermission &&
                          hasExactAlarmPermission) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainPage()),
                        );
                      }
                    });
                  });
                });
              },
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    _fetchAndScheduleNotifications();
  }

  Future<void> _fetchAndScheduleNotifications() async {
    try {
      final String? accessToken = await AuthService().accessToken;

      if (accessToken == null) {
        // Dacă accessToken este null, nu continuăm
        print("Error: Access token is null");
        return;
      }

      final DateTime startTime = DateTime.now();
      final DateTime endTime = startTime.add(const Duration(days: 7));

      // Recuperează evenimentele din Google Calendar
      List<calendar.Event> events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );

      // Programează notificările pentru fiecare eveniment
      for (var event in events) {
        if (event.start?.dateTime != null) {
          // Calculăm ora de notificare (30 de minute înainte de start)
          final DateTime eventStartTime = event.start!.dateTime!;
          final DateTime notificationTime =
              eventStartTime.subtract(const Duration(minutes: 30));

          // Planificăm notificarea
          await notificationService.scheduleNotification(
            id: event.id.hashCode,
            title: event.summary ?? 'No title',
            description: event.description ?? 'No description',
            scheduledTime: notificationTime,
          );

          print("Scheduled notification for event: ${event.summary}");
        }
      }
    } catch (e) {
      print("Error fetching events or scheduling notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: _fetchAndScheduleNotifications,
          child: const Text('Fetch Events and Schedule Notifications'),
        ),
      ),
    );
  }
}
