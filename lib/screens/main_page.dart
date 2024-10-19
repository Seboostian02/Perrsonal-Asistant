import 'package:calendar/screens/event_view_on_map.dart';
import 'package:calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'footer.dart';
import '../widgets/event_form.dart';
import '../widgets/event_list.dart';
import './not_found_page.dart';

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

  int _selectedIndex = 0;

  // Definim un GlobalKey pentru EventViewState
  final GlobalKey<EventViewState> _eventViewKey = GlobalKey<EventViewState>();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _loading = true;
    });

    Provider.of<AuthProvider>(context, listen: false);
    String? accessToken = await AuthService().accessToken;

    if (accessToken != null) {
      DateTime now = DateTime.now();
      DateTime startTime = DateTime(now.year, now.month, now.day);
      DateTime endTime = startTime.add(const Duration(days: 30));

      _events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchEvents();
    if (_selectedIndex == 1) {
      // Dacă e pe pagina de hartă
      await _setMarkersOnMap(); // Reîmprospătează marker-ele pe hartă
    }
  }

  Future<void> _setMarkersOnMap() async {
    print("chestie-------------");
    print(_eventViewKey.currentState);
    if (_eventViewKey.currentState != null) {
      await _eventViewKey.currentState!.setMarkers(_events);
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Dacă selectezi harta
      _setMarkersOnMap(); // Actualizează marker-ele pe hartă
    }
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
          // Atribuim key-ul GlobalKey widget-ului EventView
          EventView(key: _eventViewKey, events: _events),
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
