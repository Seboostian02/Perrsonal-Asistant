import 'package:calendar/screens/location_picker.dart';
import 'package:calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:calendar/services/google_calendar_service.dart';
import '../services/auth_provider.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  EventFormState createState() => EventFormState();
}

class EventFormState extends State<EventForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  LatLng? _selectedLocation;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  Future<void> _createEvent() async {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selectedDate == currentDate) {
      final nowTime = TimeOfDay.fromDateTime(now);

      if (_startTime.hour < nowTime.hour ||
          (_startTime.hour == nowTime.hour &&
              _startTime.minute <= nowTime.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start time must be later than the current time'),
          ),
        );
        return;
      }
    }

    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final accessToken = await AuthService().accessToken;
      if (accessToken != null) {
        await GoogleCalendarService.createEvent(
          accessToken: accessToken,
          title: _titleController.text,
          description: _descriptionController.text,
          location: _selectedLocation != null
              ? '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'
              : 'No location selected', // mesaj default
          date: _selectedDate,
          startTime: _startTime,
          endTime: _endTime, location_name: '',
        );

        _showTopSnackBar(context, 'Event created successfully');
        Navigator.pop(context);
      } else {
        print("Failed to get access token");
      }
    } else {
      print("User is not logged in.");
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
            color: Colors.green,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;

          if (_endTime.hour < _startTime.hour ||
              (_endTime.hour == _startTime.hour &&
                  _endTime.minute <= _startTime.minute)) {
            _endTime = picked.replacing(hour: picked.hour + 1);
          }
        } else {
          if (picked.hour < _startTime.hour ||
              (picked.hour == _startTime.hour &&
                  picked.minute <= _startTime.minute)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('End time must be after start time')),
            );
            return;
          }
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Date & Time Picker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 80,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              authProvider.isLoggedIn
                  ? Center(
                      child: Text(
                        "Time to schedule something important, ${authProvider.currentUser?.displayName ?? ''}! ",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Center(
                      child: ElevatedButton(
                        onPressed: authProvider.signInWithGoogle,
                        child: const Text('Log In with Google'),
                      ),
                    ),
              TextField(
                textAlign: TextAlign.center,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                ),
              ),
              TextField(
                textAlign: TextAlign.center,
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Event Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print("-----------------/nlocation pressed");
                  final selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationPickerPage(
                        onLocationSelected: (LatLng location) {
                          setState(() {
                            _selectedLocation = location;
                          });
                        },
                      ),
                    ),
                  );

                  if (selectedLocation != null) {
                    setState(() {
                      _selectedLocation = selectedLocation;
                    });
                  }
                },
                child: Text(
                  _selectedLocation != null
                      ? 'Selected Location: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})'
                      : 'Select Location',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Selected date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text('Pick Date'),
              ),
              const SizedBox(height: 20),
              Text(
                'Start time: ${_startTime.format(context)}',
                style: const TextStyle(fontSize: 24),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context, true),
                child: const Text('Pick Start Time'),
              ),
              const SizedBox(height: 20),
              Text(
                'End time: ${_endTime.format(context)}',
                style: const TextStyle(fontSize: 24),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context, false),
                child: const Text('Pick End Time'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
