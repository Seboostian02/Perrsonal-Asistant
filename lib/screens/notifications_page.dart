import 'package:flutter/material.dart';
import 'package:TimeBuddy/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<Map<int, List<PendingNotificationRequest>>> _pendingNotifications;

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
  }

  void _loadPendingNotifications() {
    setState(() {
      _pendingNotifications =
          NotificationService().getPendingNotifications().then((notifications) {
        // Grupăm notificările pe baza unui interval de ID-uri consecutive
        Map<int, List<PendingNotificationRequest>> groupedNotifications = {};

        // Sortăm notificările după ID pentru a putea procesa corect consecutivele
        notifications.sort((a, b) => a.id.compareTo(b.id));

        // Variabila pentru a marca grupurile deja procesate
        Set<int> processedIds = {};

        for (var notification in notifications) {
          final eventId = notification.id;

          // Verificăm dacă acest ID a fost deja procesat
          if (processedIds.contains(eventId)) {
            continue;
          }

          // Determinăm grupul de notificări consecutive
          List<PendingNotificationRequest> group = [notification];
          int currentId = eventId;

          // Adăugăm toate notificările cu ID-uri consecutive în acest grup
          while (processedIds.contains(currentId + 1) ||
              notifications.any((n) => n.id == currentId + 1)) {
            currentId++;
            var nextNotification =
                notifications.firstWhere((n) => n.id == currentId);
            group.add(nextNotification);
            processedIds.add(currentId);
          }

          // Grupăm notificările după ID-ul celui mai mic
          groupedNotifications[eventId] = group;
          processedIds.add(eventId); // Marcam primul eveniment ca procesat
        }

        return groupedNotifications;
      });
    });
  }

  String _extractEventName(String? title) {
    if (title == null || title.isEmpty) {
      return 'No Title';
    }

    final parts = title.split(' - ');
    return parts.isNotEmpty ? 'Nume eveniment: ${parts[0]}' : 'No Title';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Notificari programate',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      )),
      body: FutureBuilder<Map<int, List<PendingNotificationRequest>>>(
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
              itemCount: snapshot.data!.keys.length,
              itemBuilder: (context, index) {
                final groupId = snapshot.data!.keys.elementAt(index);
                final notifications = snapshot.data![groupId]!;

                return ExpansionTile(
                  title: Text(_extractEventName(notifications.first.title)),
                  children: notifications.map((notification) {
                    return ListTile(
                      title: Text(notification.title ?? 'No Title'),
                      subtitle: Text(notification.body ?? 'No Description'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('ID: ${notification.id}'),
                        ],
                      ),
                    );
                  }).toList(),
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
