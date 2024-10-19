import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../widgets/event_card.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class EventList extends StatelessWidget {
  final List<calendar.Event> events;
  final bool loading;

  const EventList({
    super.key,
    required this.events,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final DateTime today = DateTime.now();

    final List<calendar.Event> todayEvents = events.where((event) {
      final eventDate = event.start?.dateTime?.toLocal();
      return eventDate != null &&
          eventDate.year == today.year &&
          eventDate.month == today.month &&
          eventDate.day == today.day;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "Your events are here:",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          if (authProvider.isLoggedIn)
            ElevatedButton(
              onPressed: authProvider.signOut,
              child: const Text('Log Out'),
            )
          else
            const Text("Not logged in"),
          const SizedBox(height: 20),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (events.isEmpty)
            const Center(
              child: Text(
                "No events available.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          else ...[
            const Text(
              "Today's Events:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (todayEvents.isEmpty)
              const Center(
                child: Text(
                  "No events for today.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            else
              for (var event in todayEvents)
                EventCard(
                  event: event,
                  showLocation: true,
                ),
            const SizedBox(height: 20),
            const Text(
              "All Events:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (var event in events)
              EventCard(
                event: event,
                showLocation: true,
                key: ValueKey(event.id),
              ),
          ],
        ],
      ),
    );
  }
}
