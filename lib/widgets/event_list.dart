import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../widgets/event_card.dart';

class EventList extends StatelessWidget {
  final List<calendar.Event> events;
  final bool loading;

  const EventList({
    Key? key,
    required this.events,
    required this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final List<calendar.Event> todayEvents = events.where((event) {
      final eventDate = event.start?.dateTime?.toLocal();
      return eventDate != null &&
          eventDate.year == today.year &&
          eventDate.month == today.month &&
          eventDate.day == today.day;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Your events are here:",
          style: TextStyle(fontSize: 24),
        ),
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
                title: event.summary ?? "No Title",
                location: event.location ?? "No Location",
                description: event.description ?? "No Description",
                startTime: event.start?.dateTime?.toLocal().toString() ??
                    "No Start Time",
                endTime:
                    event.end?.dateTime?.toLocal().toString() ?? "No End Time",
              ),
          const SizedBox(height: 20),
          const Text(
            "All Events:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (var event in events)
            EventCard(
              title: event.summary ?? "No Title",
              location: event.location ?? "No Location",
              description: event.description ?? "No Description",
              startTime: event.start?.dateTime?.toLocal().toString() ??
                  "No Start Time",
              endTime:
                  event.end?.dateTime?.toLocal().toString() ?? "No End Time",
            ),
        ],
      ],
    );
  }
}
