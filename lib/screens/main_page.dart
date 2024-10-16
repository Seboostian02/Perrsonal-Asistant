import 'package:calendar/screens/event_view_on_map.dart';
import 'package:calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'footer.dart';
import '../widgets/event_form.dart';
import '../widgets/event_list.dart';
import './not_found_page.dart';
import '../services/event_service.dart';
import '../services/google_calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  List<calendar.Event> _events = [];
  bool _loading = true;
  final EventService _eventService = EventService();
  final GoogleCalendarService _googleCalendarService = GoogleCalendarService();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _loading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? accessToken = await AuthService().accessToken;

    if (accessToken != null) {
      DateTime now = DateTime.now();
      DateTime startTime = DateTime(now.year, now.month, now.day);
      DateTime endTime = startTime.add(Duration(days: 30));

      _events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );
      print("in main-----------------");
      print(_events);
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchEvents();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(authProvider.isLoggedIn
            ? "Hello, ${authProvider.currentUser?.displayName ?? 'User'}"
            : "Main App"),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: EventList(
              events: _events,
              loading: _loading,
            ),
          ),
          EventView(events: _events),
          NotFoundPage(
            onBackToHome: () => _onItemTapped(0),
          ),
          NotFoundPage(
            onBackToHome: () => _onItemTapped(0),
          ),
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
          backgroundColor: Colors.deepPurple.shade600,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
