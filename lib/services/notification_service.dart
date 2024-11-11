import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones(); // Initialize time zones

    print("Notification plugin initialized successfully.");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledTime,
  }) async {
    // Verifică dacă permisiunea pentru alarme exacte este acordată
    final permissionStatus = await Permission.notification.status;
    if (!permissionStatus.isGranted) {
      await Permission.notification.request();
      if (await Permission.notification.isGranted == false) {
        print("Notification permission not granted.");
        return;
      }
    }

    // Verifică permisiunea exactă pentru alarme
    final exactAlarmPermissionStatus = await Permission.notification.isGranted;
    if (exactAlarmPermissionStatus) {
      print("Exact alarm permission granted.");
    } else {
      print("Exact alarm permission not granted. Please enable it manually.");
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_notifications', // Channel ID
      'Event Notifications', // Channel Name
      channelDescription: 'Notifications for calendar events',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Verificăm dacă `scheduledTime` este în UTC
    print("Original scheduled time (UTC): $scheduledTime");

    // Dacă `scheduledTime` este în UTC, îl convertește în fusul orar local
    final localScheduledTime = tz.TZDateTime.from(
      scheduledTime.isUtc
          ? scheduledTime
          : scheduledTime.toUtc(), // Asigură-te că timpul este în UTC
      tz.local,
    );

    // Verificăm rezultatul conversiei
    print("Scheduled time converted to local time: $localScheduledTime");

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        description,
        localScheduledTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      print("Notification scheduled successfully!");
    } catch (e) {
      print("Error scheduling notification: $e");
    }

    print(
        "Notification details - ID: $id, Title: $title, Description: $description, ScheduledTime: $scheduledTime");
  }
}
