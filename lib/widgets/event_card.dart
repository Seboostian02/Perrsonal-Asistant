import 'package:calendar/screens/event_view_on_map.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class EventCard extends StatelessWidget {
  final calendar.Event event;
  final bool showLocation;
  static const Color cardColor = Color(0xFFE1BEE7);

  const EventCard({
    Key? key,
    required this.event,
    this.showLocation = false,
  }) : super(key: key);

  void _onLocationTap(BuildContext context) {
    if (showLocation) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            child: EventView(
              events: [event],
              showBackArrow: true,
              showRoute: true,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateTime = DateTime.parse(event.start!.dateTime!.toString());
    final endDateTime = DateTime.parse(event.end!.dateTime!.toString());
    final String startHour =
        "${startDateTime.hour}:${startDateTime.minute.toString().padLeft(2, '0')}";
    final String endHour =
        "${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}";

    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(startDateTime);

    String location = event.location ?? "No Location";
    List<String> locationParts;

    if (location.length > 30) {
      int midPoint = (location.length / 2).round();
      locationParts = [
        location.substring(0, midPoint),
        location.substring(midPoint)
      ];
    } else {
      locationParts = [location];
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.summary ?? "No Title",
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              event.description ?? "No Description",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _onLocationTap(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location:',
                    style: TextStyle(
                      fontSize: 16,
                      color: showLocation ? Colors.blue : Colors.grey,
                      decoration: showLocation
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                  ...locationParts.map((part) => Text(
                        part,
                        style: TextStyle(
                          fontSize: 16,
                          color: showLocation ? Colors.blue : Colors.grey,
                          decoration: showLocation
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Starts at: $startHour',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ends at: $endHour',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
