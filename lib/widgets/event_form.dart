import 'package:calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/google_calendar_service.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  void _createEvent() {
    GoogleCalendarService.createEvent(
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
    );
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

          if (_endTime.hour <= _startTime.hour &&
              _endTime.minute <= _startTime.minute) {
            _endTime = picked.replacing(hour: picked.hour + 1);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date & Time Picker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(90.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    AuthService().signInWithGoogle();
                  },
                  child: const Text('Log In with google')),
              TextField(
                  textAlign: TextAlign.center,
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title',
                  )),
              TextField(
                textAlign: TextAlign.center,
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Event Description'),
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
