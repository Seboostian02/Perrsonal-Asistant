import 'package:calendar/services/auth_service.dart';
import 'package:calendar/services/notification_service.dart';
import 'package:calendar/utils/colors.dart';
import 'package:calendar/widgets/event_form_components/date_selector.dart';
import 'package:calendar/widgets/event_form_components/event_description_field.dart';
import 'package:calendar/widgets/event_form_components/event_title_field.dart';
import 'package:calendar/widgets/event_form_components/location_selector.dart';
import 'package:calendar/widgets/event_form_components/priority_selector.dart';
import 'package:calendar/widgets/event_form_components/reccurence_selector.dart';
import 'package:calendar/widgets/event_form_components/time_selector.dart';
import 'package:calendar/widgets/event_form_components/user_greeting.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:calendar/services/google_calendar_service.dart';
import '../models/recurrence_type.dart';
import '../services/auth_provider.dart';

enum RecurrenceType { none, daily, weekly, monthly }

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  EventFormState createState() => EventFormState();
}

class EventFormState extends State<EventForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String selectedPriority = 'Low';

  LatLng? _selectedLocation;
  bool _isOnlineMeeting = false;
  DateTime _selectedDate = DateTime.now().toUtc();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  RecurrenceType _recurrenceType = RecurrenceType.none;
  DateTime? _recurrenceEndDate;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = TimeOfDay(hour: now.hour, minute: (now.minute + 15) % 60);
    _endTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
  }

  Future<void> _selectRecurrenceEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _recurrenceEndDate) {
      setState(() {
        _recurrenceEndDate = picked;
      });
    }
  }

  Future<void> _createEvent() async {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    final selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    if (_recurrenceType != RecurrenceType.none && _recurrenceEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recurrence end date'),
        ),
      );
      return;
    }
    if (_recurrenceType == RecurrenceType.none && selectedDate == currentDate) {
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
      if (accessToken == null) {
        print("Failed to get access token");
        return;
      }

      await GoogleCalendarService.createEvent(
        accessToken: accessToken,
        title: _titleController.text,
        description: _descriptionController.text,
        priority: selectedPriority,
        location: _isOnlineMeeting
            ? 'Event is online'
            : _selectedLocation != null
                ? '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'
                : 'No location specified',
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        location_name: '',
        recurrenceEndDate: _recurrenceEndDate,
        recurrenceType: _recurrenceType,
      );

      _showTopSnackBar(context, 'Event created successfully');
      Navigator.pop(context);
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
      initialEntryMode: TimePickerEntryMode.input,
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Event',
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: _createEvent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: AppColors.iconColor.withOpacity(0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.iconColor,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 90,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.iconColor),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const UserGreeting(),
                EventTitleField(controller: _titleController),
                EventDescriptionField(controller: _descriptionController),
                DateSelector(
                  selectedDate: _selectedDate,
                  onDateSelected: _selectDate,
                ),
                TimeSelector(
                  startTime: _startTime,
                  endTime: _endTime,
                  onTimeSelected: _selectTime,
                ),
                const SizedBox(height: 20),
                // Wrap PrioritySelector and Online Meeting in a Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PrioritySelector cu lățime mai mică
                    Container(
                      width: 130, // Ajustează această valoare după necesități
                      child: PrioritySelector(
                        selectedPriority: selectedPriority,
                        onPriorityChanged: (String? newPriority) {
                          if (newPriority != null) {
                            setState(() {
                              selectedPriority = newPriority;
                            });
                          }
                        },
                      ),
                    ),

                    // CheckboxListTile cu lățime mai mare
                    Container(
                      width: 200, // Ajustează această valoare după necesități
                      child: CheckboxListTile(
                        title: const Text('Online meeting?'),
                        value: _isOnlineMeeting,
                        onChanged: (bool? value) {
                          setState(() {
                            _isOnlineMeeting = value ?? false;
                            if (_isOnlineMeeting) {
                              _selectedLocation = null;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                if (!_isOnlineMeeting)
                  CheckboxListTile(
                    title: const Text('Add a location for this event?'),
                    value: _selectedLocation != null,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedLocation = LatLng(0, 0);
                        } else {
                          _selectedLocation = null;
                        }
                      });
                    },
                  ),
                if (_selectedLocation != null)
                  LocationSelector(
                    selectedLocation: _selectedLocation,
                    onLocationSelected: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    selectedLocationName: '',
                  ),

                RecurrenceSelector(
                  recurrenceType: _recurrenceType,
                  recurrenceEndDate: _recurrenceEndDate,
                  onRecurrenceChanged: (RecurrenceType? newRecurrenceType) {
                    setState(() {
                      _recurrenceType =
                          newRecurrenceType ?? RecurrenceType.none;
                      _recurrenceEndDate = null;
                    });
                  },
                  onEndDateChanged: (DateTime? newEndDate) {
                    setState(() {
                      _recurrenceEndDate = newEndDate;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
