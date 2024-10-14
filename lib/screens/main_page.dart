import 'package:calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'footer.dart';
import '../widgets/event_form.dart';
import '../widgets/event_card.dart';
import '../services/google_calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<calendar.Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final String? accessToken = await AuthService().accessToken;

    if (accessToken != null) {
      DateTime now = DateTime.now();
      DateTime startTime =
          now.subtract(const Duration(hours: 12)); // 12 ore în urma
      DateTime endTime =
          now.add(const Duration(days: 365 * 10)); // event pe 10 ani
      List<calendar.Event> events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );

      setState(() {
        _events = events;
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loading = true;
    });
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(authProvider.isLoggedIn
            ? "Hello, ${authProvider.currentUser?.displayName ?? 'User'}"
            : "Main App"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              for (var event in _events)
                EventCard(
                  title: event.summary ?? "No Title",
                  location: event.location ?? "No Location",
                  description: event.description ?? "No Description",
                  startTime: event.start?.dateTime?.toLocal().toString() ??
                      "No Start Time",
                  endTime: event.end?.dateTime?.toLocal().toString() ??
                      "No End Time",
                ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
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
