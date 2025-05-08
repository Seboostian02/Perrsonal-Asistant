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
    tz.initializeTimeZones();

    print("Notification plugin initialized successfully.");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledTime,
  }) async {
    print("notification time ----------- $scheduledTime");
    final permissionStatus = await Permission.notification.status;
    if (!permissionStatus.isGranted) {
      await Permission.notification.request();
      if (!await Permission.notification.isGranted) {
        print("Notification permission not granted.");
        return;
      }
    }

    final exactAlarmPermissionStatus = await Permission.notification.isGranted;
    if (!exactAlarmPermissionStatus) {
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

    final localScheduledTime = tz.TZDateTime.from(
      scheduledTime.isUtc ? scheduledTime : scheduledTime.toUtc(),
      tz.local,
    );

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

  Future<void> scheduleEventNotifications({
    required int id,
    required String title,
    required String description,
    required DateTime eventStartTime,
  }) async {
    final List<Map<String, dynamic>> notificationTimes = [
      {
        "time": eventStartTime.subtract(const Duration(hours: 24)),
        "suffix": " - 24 ore inante"
      },
      {
        "time": eventStartTime.subtract(const Duration(hours: 1)),
        "suffix": " - 1 ore inante"
      },
      {
        "time": eventStartTime.subtract(const Duration(minutes: 30)),
        "suffix": " - 30 minute inainte"
      },
      {"time": eventStartTime, "suffix": " - Start eveniment"},
    ];

    for (int i = 0; i < notificationTimes.length; i++) {
      final notificationTime = notificationTimes[i]["time"] as DateTime;
      final suffix = notificationTimes[i]["suffix"] as String;
      final notificationTitle = "$title$suffix";

      await scheduleNotification(
        id: id + i,
        title: notificationTitle,
        description: description,
        scheduledTime: notificationTime,
      );
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print("Error fetching pending notifications: $e");
      return [];
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print("Notification with ID $id canceled.");
    } catch (e) {
      print("Error canceling notification with ID $id: $e");
    }
  }
}
