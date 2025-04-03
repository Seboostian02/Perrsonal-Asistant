import 'package:TimeBuddy/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../widgets/event_card.dart';
import 'package:intl/date_symbol_data_local.dart';

class EventCalendar extends StatefulWidget {
  final List<calendar.Event> events;
  final VoidCallback onRefresh;

  const EventCalendar({
    Key? key,
    required this.events,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _EventCalendarState createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime _selectedDay;
  late Map<DateTime, List<calendar.Event>> _eventMap;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ro', null);
    _selectedDay = DateTime.now().toLocal();
    _eventMap = _groupEventsByDate();
  }

  Map<DateTime, List<calendar.Event>> _groupEventsByDate() {
    Map<DateTime, List<calendar.Event>> eventMap = {};
    for (var event in widget.events) {
      final eventDate = event.start?.dateTime?.toLocal();
      if (eventDate != null) {
        final date = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (eventMap[date] == null) {
          eventMap[date] = [];
        }
        eventMap[date]!.add(event);
      }
    }
    return eventMap;
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSelectedDay =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final eventsForSelectedDay = _eventMap[normalizedSelectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar evenimente'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _selectedDay,
                    locale: 'ro',
                    headerStyle: HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay.toLocal();
                      });
                    },
                    eventLoader: (day) => _eventMap[day] ?? [],
                    holidayPredicate: (day) => _eventMap.containsKey(
                      DateTime(day.year, day.month, day.day),
                    ),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primaryLightColor,
                        shape: BoxShape.circle,
                      ),
                      holidayDecoration: BoxDecoration(
                        color: AppColors.secondaryLightColor,
                        shape: BoxShape.circle,
                      ),
                      holidayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      cellMargin: EdgeInsets.all(4.0),
                      markersMaxCount: 1,
                      markersAlignment: Alignment.bottomCenter,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Evenimente pentru ${DateFormat('d MMMM yyyy', 'ro').format(_selectedDay)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (eventsForSelectedDay.isNotEmpty) ...[
                          const Center(
                            child: Text(
                              'Ai evenimente pentru astăzi!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: eventsForSelectedDay.length,
                              itemBuilder: (context, index) {
                                final event = eventsForSelectedDay[index];
                                return EventCard(
                                  event: event,
                                  showLocation: true,
                                  onDelete: widget.onRefresh,
                                );
                              },
                            ),
                          ),
                        ] else
                          const Center(
                            child: Text(
                              "No events for today.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
