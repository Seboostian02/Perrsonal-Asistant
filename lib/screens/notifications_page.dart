import 'package:flutter/material.dart';
import 'package:calendar/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Modificăm structura datelor în NotificationService.dart
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<PendingNotificationRequest>> _pendingNotifications;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  void _loadPendingNotifications() {
    setState(() {
      _pendingNotifications = NotificationService().getPendingNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Notifications')),
      body: FutureBuilder<List<PendingNotificationRequest>>(
        future: _pendingNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scheduled notifications'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data![index];
                return ListTile(
                  title: Text(notification.title ?? 'No Title'),
                  subtitle: Text(notification.body ?? 'No Description'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ID: ${notification.id}'),
                      SizedBox(height: 4),
                      Text('timp progrmat ${notification.body}')
                      // 'Timp programat: ${_formatDateTime(notification.scheduledTime)}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
