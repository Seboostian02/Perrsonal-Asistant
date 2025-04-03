import 'package:TimeBuddy/screens/event_view_on_map.dart';
import 'package:TimeBuddy/services/auth_provider.dart';
import 'package:TimeBuddy/services/auth_service.dart';
import 'package:TimeBuddy/services/google_calendar_service.dart';
import 'package:TimeBuddy/utils/colors.dart';
import 'package:TimeBuddy/widgets/edit_event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class EventCard extends StatefulWidget {
  final calendar.Event event;
  final bool showLocation;
  final bool expandMode;
  final bool editEvent;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  static const Color cardColor = AppColors.primaryLightColor;

  const EventCard({
    Key? key,
    required this.event,
    this.showLocation = false,
    this.expandMode = false,
    this.editEvent = true,
    this.onDelete,
    this.onEdit,
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
    initializeDateFormatting('ro', null);
    _isExpanded = widget.expandMode;
  }

  String _translatePriority(String priority) {
    switch (priority) {
      case 'Medium':
        return 'Medie';
      case 'High':
        return 'Ridicata';
      default:
        return 'Scazuta';
    }
  }

  void _showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          elevation: 6.0,
          child: Container(
            color: Colors.red,
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  void _updateEvent(BuildContext context) async {
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
            title: const Text("Editare eveniment"),
            content: isRecurring
                ? const Text(
                    "Doriți să editați acest eveniment sau întreaga serie?")
                : const Text("Sigur doriți să editați acest eveniment?"),
            actions: [
              if (isRecurring) ...[
                TextButton(
                  onPressed: () {
                    editSeries = false;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Acest eveniment"),
                ),
                TextButton(
                  onPressed: () {
                    editSeries = true;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Întreaga serie"),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Nu"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Da"),
                ),
              ],
            ],
          );
        },
      );
      void _handleEventUpdate(
          BuildContext context, calendar.Event updatedEvent) async {
        TimeOfDay startTime =
            TimeOfDay.fromDateTime(updatedEvent.start!.dateTime!.toLocal());
        TimeOfDay endTime =
            TimeOfDay.fromDateTime(updatedEvent.end!.dateTime!.toLocal());

        String eventId = editSeries ? mainEventId : widget.event.id!;

        await GoogleCalendarService.updateEvent(
          accessToken: accessToken,
          eventId: eventId,
          title: updatedEvent.summary!,
          description: updatedEvent.description ?? '',
          date: updatedEvent.start!.dateTime!.toLocal(),
          startTime: startTime,
          endTime: endTime,
          location: updatedEvent.location ?? '',
          priority:
              updatedEvent.extendedProperties!.private!['priority'] ?? 'Low',
          updateSeries: editSeries,
        );

        print('Evenimentul a fost actualizat cu succes în Google Calendar');
      }

      if (confirmedEdit) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: EditEventForm(
                event: widget.event,
                onEdit: widget.onEdit,
                editSeries: editSeries,
                onUpdate: (updatedEvent) {
                  _handleEventUpdate(context, updatedEvent);
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
              // showBackArrow: true,
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
            title: const Text("Ștergere eveniment"),
            content: isRecurring
                ? const Text(
                    "Doriți să ștergeți acest eveniment sau întreaga serie?")
                : const Text("Sigur doriți să ștergeți acest eveniment?"),
            actions: [
              if (isRecurring) ...[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Acest eveniment"),
                ),
                TextButton(
                  onPressed: () {
                    deleteSeries = true;
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Toată seria"),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Nu"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Da"),
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
        DateFormat('EEEE, d MMMM yyyy', 'ro').format(startDateTime);

    String location = widget.event.location ?? "Nici o locație";
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
                  if (widget.showLocation)
                    Text(
                      'prioritate - ${_translatePriority(priority)}',
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
                      onPressed: () => _updateEvent(context),
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
                      widget.event.description ?? "Nici o descriere",
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
                            'Locație:',
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
                      'Dată: $formattedDate',
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
                              'Oră start: $startHour',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Oră sfârșit: $endHour',
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
