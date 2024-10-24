import 'package:calendar/screens/event_view_on_map.dart';
import 'package:calendar/services/auth_provider.dart';
import 'package:calendar/services/auth_service.dart';
import 'package:calendar/services/google_calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:provider/provider.dart';

class EventCard extends StatefulWidget {
  final calendar.Event event;
  final bool showLocation;
  final bool expandMode;
  final VoidCallback? onDelete;
  static const Color cardColor = Color(0xFFE1BEE7);

  const EventCard({
    Key? key,
    required this.event,
    this.showLocation = false,
    this.expandMode = false,
    this.onDelete,
  }) : super(key: key);

  @override
  EventCardState createState() => EventCardState();
}

class EventCardState extends State<EventCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();

    _isExpanded = widget.expandMode;
  }

  void _onLocationTap(BuildContext context) {
    if (widget.showLocation) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: EdgeInsets.zero,
            child: EventView(
              events: [widget.event],
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
    final startDateTime =
        DateTime.parse(widget.event.start!.dateTime!.toString());
    final endDateTime = DateTime.parse(widget.event.end!.dateTime!.toString());
    final String startHour =
        "${startDateTime.hour}:${startDateTime.minute.toString().padLeft(2, '0')}";
    final String endHour =
        "${endDateTime.hour}:${endDateTime.minute.toString().padLeft(2, '0')}";

    final String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(startDateTime);

    String location = widget.event.location ?? "No Location";
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.expandMode
          ? 300
          : (_isExpanded ? MediaQuery.of(context).size.width : 200),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: EventCard.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.event.summary ?? "No Title",
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.w800),
                  ),
                  if (!widget.expandMode)
                    IconButton(
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isExpanded ? 0.5 : 0,
                        child: Icon(_isExpanded
                            ? Icons.expand_more
                            : Icons.chevron_left),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              if (_isExpanded || widget.expandMode)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.description ?? "No Description",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
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
                              color: widget.showLocation
                                  ? Colors.blue
                                  : Colors.grey,
                              decoration: widget.showLocation
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                          ...locationParts.map((part) => Text(
                                part,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.showLocation
                                      ? Colors.blue
                                      : Colors.grey,
                                  decoration: widget.showLocation
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                        if (!widget.expandMode)
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: () async {
                                Provider.of<AuthProvider>(context,
                                    listen: false);
                                final accessToken =
                                    await AuthService().accessToken;

                                if (accessToken != null) {
                                  await GoogleCalendarService.deleteEvent(
                                    accessToken: accessToken,
                                    eventId: widget.event.id!,
                                  );

                                  if (widget.onDelete != null) {
                                    widget.onDelete!();
                                  }
                                } else {
                                  print(
                                      "Failed to get access token for Google Calendar");
                                }
                              },
                            ),
                          )
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
