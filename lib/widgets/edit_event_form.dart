import 'package:calendar/widgets/event_form_components/location_selector.dart';
import 'package:calendar/widgets/event_form_components/priority_selector.dart';
import 'package:calendar/widgets/event_form_components/reccurence_selector.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import 'package:calendar/models/recurrence_type.dart' as model_recurrence;

class EditEventForm extends StatefulWidget {
  final calendar.Event event;
  final Function(calendar.Event) onUpdate;
  final VoidCallback? onEdit;
  final bool editSeries;

  const EditEventForm({
    Key? key,
    required this.event,
    required this.onUpdate,
    required this.editSeries,
    this.onEdit,
  }) : super(key: key);

  @override
  _EditEventFormState createState() => _EditEventFormState();
}

class _EditEventFormState extends State<EditEventForm> {
  late TextEditingController _summaryController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isDateLocked;
  LatLng? _selectedLocation;
  String _selectedPriority = 'Low';
  model_recurrence.RecurrenceType _recurrenceType =
      model_recurrence.RecurrenceType.none;
  DateTime? _recurrenceEndDate;
  String? _errorMessage;
  String? _timeErrorMessage;

  @override
  void initState() {
    super.initState();
    _summaryController = TextEditingController(text: widget.event.summary);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _selectedDate =
        DateTime.parse(widget.event.start!.dateTime!.toString()).toLocal();
    _startTime = TimeOfDay.fromDateTime(
        DateTime.parse(widget.event.start!.dateTime!.toString()).toLocal());
    _endTime = TimeOfDay.fromDateTime(
        DateTime.parse(widget.event.end!.dateTime!.toString()).toLocal());

    _selectedPriority =
        widget.event.extendedProperties?.private?['priority'] ?? 'Low';

    _isDateLocked =
        widget.editSeries; // Blochează modificarea datei dacă editezi seria

    if (widget.event.location != null) {
      if (widget.event.location!.contains(',')) {
        final locationParts = widget.event.location!.split(',');
        try {
          _selectedLocation = LatLng(
            double.parse(locationParts[0]),
            double.parse(locationParts[1]),
          );
        } catch (e) {
          _selectedLocation = null;
        }
      } else {
        _selectedLocation = null;
      }
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (_isDateLocked) {
      setState(() {
        _errorMessage = "You cannot edit the date for a recurring series.";
      });
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null; // Resetează mesajul de eroare
      });
    }
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;

          // Verificăm dacă start time depășește end time
          if (_startTime.hour > _endTime.hour ||
              (_startTime.hour == _endTime.hour &&
                  _startTime.minute >= _endTime.minute)) {
            _timeErrorMessage = "Start time must be earlier than end time.";
          } else {
            _timeErrorMessage = null; // Resetăm eroarea dacă timpul este valid
          }
        } else {
          _endTime = picked;

          // Verificăm dacă end time este mai mic decât start time
          if (_endTime.hour < _startTime.hour ||
              (_endTime.hour == _startTime.hour &&
                  _endTime.minute <= _startTime.minute)) {
            _timeErrorMessage = "End time must be later than start time.";
          } else {
            _timeErrorMessage = null; // Resetăm eroarea dacă timpul este valid
          }
        }
      });
    }
  }

  void _saveChanges() {
    widget.event.summary = _summaryController.text;
    widget.event.description = _descriptionController.text;
    widget.event.location = _selectedLocation != null
        ? '${_selectedLocation!.latitude},${_selectedLocation!.longitude}'
        : null;

    widget.event.extendedProperties ??= calendar.EventExtendedProperties(
      private: {},
    );
    widget.event.extendedProperties!.private!['priority'] = _selectedPriority;

    DateTime startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime endDateTime;
    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute < _startTime.minute)) {
      // Setăm endDateTime pentru ziua următoare
      endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + 1,
        _endTime.hour,
        _endTime.minute,
      );
    } else {
      endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );
    }

    widget.event.start = calendar.EventDateTime(dateTime: startDateTime);
    widget.event.end = calendar.EventDateTime(dateTime: endDateTime);

    if (_recurrenceType != model_recurrence.RecurrenceType.none) {
      widget.event.recurrence = [
        'RRULE:FREQ=${_recurrenceType.name.toUpperCase()}${_recurrenceEndDate != null ? ';UNTIL=${DateFormat('yyyyMMdd').format(_recurrenceEndDate!)}' : ''}'
      ];
    }

    widget.onUpdate(widget.event);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    String locationDisplay = "No location set";
    bool isOnline = false;

    if (widget.event.location != null) {
      if (_selectedLocation != null) {
        locationDisplay =
            "Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}";
      } else {
        locationDisplay = widget.event.location!;
        if (locationDisplay.toLowerCase() == "online") {
          isOnline = true;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text("Event Location: $locationDisplay"),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isOnline,
                      onChanged: (bool? value) {
                        setState(() {
                          isOnline = value ?? false;
                          if (isOnline) {
                            widget.event.location = "Online";
                            _selectedLocation = null;
                          } else {
                            widget.event.location = null;
                          }
                        });
                      },
                    ),
                    const Text("Set as Online"),
                  ],
                ),
                if (!isOnline)
                  LocationSelector(
                    selectedLocation: _selectedLocation,
                    selectedLocationName: locationDisplay,
                    onLocationSelected: (location) {
                      setState(() {
                        _selectedLocation = location;
                        widget.event.location =
                            '${location.latitude},${location.longitude}';
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPriorityChanged: (priority) {
                setState(() {
                  _selectedPriority = priority ?? 'Low';
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                  "Event Date: ${DateFormat.yMMMd().format(_selectedDate)}"),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
            if (_isDateLocked && _errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ListTile(
              title: Text("Start Time: ${_startTime.format(context)}"),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _pickTime(isStartTime: true),
              ),
            ),
            ListTile(
              title: Text("End Time: ${_endTime.format(context)}"),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => _pickTime(isStartTime: false),
              ),
            ),
            if (_timeErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _timeErrorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _timeErrorMessage == null ? () => _saveChanges() : null,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
