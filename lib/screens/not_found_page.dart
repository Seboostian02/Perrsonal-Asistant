import 'package:flutter/material.dart';
import 'package:TimeBuddy/services/notification_service.dart';

class NotFoundPage extends StatelessWidget {
  final VoidCallback onBackToHome;
  final NotificationService notificationService;

  const NotFoundPage({
    super.key,
    required this.onBackToHome,
    required this.notificationService,
  });

  void _scheduleTestNotification() {
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 5));
    print("now------------");
    print(now);

    notificationService.scheduleNotification(
      id: 0,
      title: "Test Notification",
      description: "This is a test notification for 5 seconds later.",
      scheduledTime: scheduledTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page Not Found"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                onBackToHome();
              },
              child: const Text("Go Back to Home"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleTestNotification,
              child: const Text("Schedule Test Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
