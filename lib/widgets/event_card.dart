import 'package:calendar/screens/event_view_on_map.dart';
import 'package:calendar/services/auth_provider.dart';
import 'package:calendar/services/auth_service.dart';
import 'package:calendar/services/google_calendar_service.dart';
import 'package:calendar/utils/colors.dart';
import 'package:calendar/widgets/edit_event_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:provider/provider.dart';

class EventCard extends StatefulWidget {
  final calendar.Event event;
  final bool showLocation;
  final bool expandMode;
  final bool editEvent;
  final VoidCallback? onDelete;
  static const Color cardColor = AppColors.primaryLightColor;

  const EventCard({
    Key? key,
    required this.event,
    this.showLocation = false,
    this.expandMode = false,
    this.editEvent = true,
    this.onDelete,
  }) : super(key: key);

  @override
  EventCardState createState() => EventCardState();
}

class EventCardState extends State<EventCard> {
  late bool _isExpanded;

  // Mapping priority to colors
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Medium':
        return AppColors
            .mediumPriorityColor; // Example color for 'Medium' priority
      case 'High':
        return AppColors.highPriorityColor; // Example color for 'High' priority
      default:
        return AppColors.lowPriorityColor; // Default color for 'Low' priority
    }
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expandMode;
  }

  void _showEditDialog(BuildContext context) async {
    final accessToken = await AuthService().accessToken;

    if (accessToken != null) {
      final client =
          await GoogleCalendarService.getAuthenticatedClient(accessToken);
      final calendarApi = calendar.CalendarApi(client);

      String mainEventId = widget.event.id!.split('_')[0];

      final recurringEventIds =
          await GoogleCalendarService.getRecurringEventIds(
        calendarApi,
        widget.event.id!,
        widget.event.id!,
      );

      bool isRecurring = recurringEventIds.contains(mainEventId);
      bool editSeries = false;

      bool confirmedEdit = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit Event"),
            content: isRecurring
                ? const Text(
                    "Do you want to edit this event or the entire series?")
                : const Text("Are you sure you want to edit this event?"),
            actions: [
              if (isRecurring) ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("This Event"),
                ),
                TextButton(
                  onPressed: () {
                    editSeries = true;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Entire Series"),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
              ],
            ],
          );
        },
      );

      if (confirmedEdit) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: EditEventForm(
                event: widget.event,
                onUpdate: (updatedEvent) async {
                  setState(() {
                    widget.event.summary = updatedEvent.summary;
                    widget.event.description = updatedEvent.description;
                    widget.event.location = updatedEvent.location;
                    // Actualizare prioritate
                    widget.event.extendedProperties ??=
                        calendar.EventExtendedProperties(
                      private: {},
                    );
                    widget.event.extendedProperties!.private!['priority'] =
                        updatedEvent.extendedProperties!.private!['priority']!;
                  });

                  try {
                    if (updatedEvent.summary == null ||
                        updatedEvent.summary!.isEmpty) {
                      throw Exception('Title cannot be empty');
                    }
                    if (updatedEvent.start?.dateTime == null) {
                      throw Exception('Start time cannot be null');
                    }
                    if (updatedEvent.end?.dateTime == null) {
                      throw Exception('End time cannot be null');
                    }

                    // Convertește DateTime în TimeOfDay
                    TimeOfDay startTime = TimeOfDay.fromDateTime(
                        updatedEvent.start!.dateTime!.toLocal());
                    TimeOfDay endTime = TimeOfDay.fromDateTime(
                        updatedEvent.end!.dateTime!.toLocal());

                    String eventId =
                        editSeries ? mainEventId : widget.event.id!;

                    // Trimite la Google Calendar
                    await GoogleCalendarService.updateEvent(
                      accessToken: accessToken,
                      eventId: eventId,
                      title: updatedEvent.summary!,
                      description: updatedEvent.description ?? '',
                      date: updatedEvent.start!.dateTime!.toLocal(),
                      startTime: startTime,
                      endTime: endTime,
                      location: updatedEvent.location ?? '',
                      priority: updatedEvent
                              .extendedProperties!.private!['priority'] ??
                          'Low',
                      updateSeries: editSeries,
                    );

                    print('Event updated successfully in Google Calendar');
                  } catch (error) {
                    print('Error updating event in Google Calendar: $error');
                  }
                },
              ),
            );
          },
        );
      }
    } else {
      print("Failed to get access token for Google Calendar");
    }
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

  Future<void> _deleteEvent(BuildContext context) async {
    Provider.of<AuthProvider>(context, listen: false);
    final accessToken = await AuthService().accessToken;

    if (accessToken != null) {
      final client =
          await GoogleCalendarService.getAuthenticatedClient(accessToken);
      final calendarApi = calendar.CalendarApi(client);

      String mainEventId = widget.event.id!.split('_')[0];

      final recurringEventIds =
          await GoogleCalendarService.getRecurringEventIds(
        calendarApi,
        widget.event.id!,
        widget.event.id!,
      );

      bool isRecurring = recurringEventIds.contains(mainEventId);
      bool deleteSeries = false;

      bool confirmedDelete = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Event"),
            content: isRecurring
                ? const Text(
                    "Do you want to delete this event or the entire series?")
                : const Text("Are you sure you want to delete this event?"),
            actions: [
              if (isRecurring) ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("This Event"),
                ),
                TextButton(
                  onPressed: () {
                    deleteSeries = true;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Entire Series"),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
              ],
            ],
          );
        },
      );

      if (confirmedDelete) {
        if (deleteSeries) {
          await GoogleCalendarService.deleteEvent(
            accessToken: accessToken,
            eventId: mainEventId,
            deleteRecurrence: true,
          );
        } else {
          await GoogleCalendarService.deleteEvent(
            accessToken: accessToken,
            eventId: widget.event.id!,
            deleteRecurrence: false,
          );
        }

        if (widget.onDelete != null) {
          widget.onDelete!();
        }
      }
    } else {
      print("Failed to get access token for Google Calendar");
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateTime =
        DateTime.parse(widget.event.start!.dateTime!.toString()).toLocal();
    final endDateTime =
        DateTime.parse(widget.event.end!.dateTime!.toString()).toLocal();
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

    String priority =
        widget.event.extendedProperties?.private?['priority'] ?? 'Low';

    // Get the color for the card based on priority
    Color cardColor = _getPriorityColor(priority);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.expandMode
          ? 300
          : (_isExpanded ? MediaQuery.of(context).size.width : 200),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: cardColor, // Use the priority-based color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.event.summary ?? "No Title",
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.w800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'priority - ($priority)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.editEvent && _isExpanded) // Buton de editare
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(context),
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
                                  ? AppColors.linkColor
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
                                      ? AppColors.linkColor
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
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.iconColor),
                              onPressed: () => _deleteEvent(context),
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
