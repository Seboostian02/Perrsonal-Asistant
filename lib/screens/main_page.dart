import 'package:calendar/screens/event_view_on_map.dart';
import 'package:calendar/screens/profile_page.dart';
import 'package:calendar/screens/settings.dart';
import 'package:calendar/screens/weather_view.dart';
import 'package:calendar/services/auth_service.dart';
import 'package:calendar/services/event_provider.dart';
import 'package:calendar/services/location_service.dart';
import 'package:calendar/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'footer.dart';
import '../widgets/event_form.dart';
import 'event_list.dart';
import './not_found_page.dart';
import '../services/google_calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:geolocator/geolocator.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  bool _loading = true;
  int _selectedIndex = 0;
  final GlobalKey<EventViewState> _eventViewKey = GlobalKey<EventViewState>();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchAndScheduleNotifications();
    _getCurrentLocation();
  }

  Future<void> _fetchAndScheduleNotifications() async {
    await _fetchEvents();
    await _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    final events = Provider.of<EventProvider>(context, listen: false).events;
    final pendingNotifications =
        await notificationService.getPendingNotifications();

    for (var notification in pendingNotifications) {
      int modifiedEventId = notification.id;
      if (!events.any(
          (event) => event.id.hashCode.abs() % 10000000 == modifiedEventId)) {
        await notificationService.cancelNotification(modifiedEventId);
        print("Notification for event with ID $modifiedEventId canceled.");
      }
    }

    for (var event in events) {
      if (event.start?.dateTime != null) {
        final DateTime eventStartTime = event.start!.dateTime!.toLocal();
        print("event start time ----- $eventStartTime");

        int notificationId = event.id.hashCode.abs() % 10000000;

        final String formattedStartTime =
            DateFormat('HH:mm').format(eventStartTime);

        await notificationService.scheduleEventNotifications(
          id: notificationId,
          title:
              '${event.summary ?? 'No title'} - starting at $formattedStartTime',
          description: event.description ?? 'No description',
          eventStartTime: eventStartTime,
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await LocationService().getCurrentLocation();
      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _loading = true;
    });

    String? accessToken = await AuthService().accessToken;

    if (accessToken != null) {
      DateTime now = DateTime.now();
      DateTime startTime = DateTime(now.year, now.month, now.day);
      DateTime endTime = startTime.add(const Duration(days: 30));

      List<calendar.Event> events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );

      if (events.isNotEmpty) {
        Provider.of<EventProvider>(context, listen: false).setEvents(events);
      } else {
        Provider.of<EventProvider>(context, listen: false).clearEvents();
      }

      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchAndScheduleNotifications();
    if (_selectedIndex == 1) {
      await _setMarkersOnMap();
    }
  }

  Future<void> _setMarkersOnMap() async {
    final events = Provider.of<EventProvider>(context, listen: false).events;

    if (events.isNotEmpty && _eventViewKey.currentState != null) {
      await _eventViewKey.currentState!.setMarkers(events);
    }
  }

  void _showEventForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16.0),
        child: EventForm(),
      ),
    ).then((_) {
      _onRefresh();
    });
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Rulează doar pentru EventView
      await _onRefresh();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshEvents() async {
    await _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    print("events in main ------------");
    print(eventProvider.events);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          authProvider.isLoggedIn
              ? "Hello, ${authProvider.currentUser?.displayName ?? 'User'}"
              : "Main App",
          style: TextStyle(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.iconColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _onItemTapped(4);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: EventList(
              events: eventProvider.events,
              loading: _loading,
              onRefresh: _refreshEvents,
            ),
          ),
          eventProvider.events.isNotEmpty
              ? EventView(
                  key: _eventViewKey,
                  events: eventProvider.events,
                  showCurrLocation: true,
                  showRoute: false,
                )
              : const Center(child: CircularProgressIndicator()),
          _currentPosition != null
              ? WeatherView(
                  location: _currentPosition!,
                )
              : const Center(child: CircularProgressIndicator()),
          const ProfilePage(),
          // NotFoundPage(
          //   onBackToHome: () => _onItemTapped(0),
          //   notificationService: notificationService,
          // ),
          SettingsList(authProvider: authProvider),
        ],
      ),
      bottomNavigationBar: Footer(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: FloatingActionButton(
          onPressed: () => _showEventForm(context),
          backgroundColor: AppColors.secondaryColor,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: AppColors.iconColor,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
