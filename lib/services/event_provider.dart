import 'package:calendar/services/auth_service.dart';
import 'package:calendar/services/google_calendar_service.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:calendar/widgets/event_form.dart';

class EventProvider with ChangeNotifier {
  List<calendar.Event> _events = [];
  List<calendar.Event> get events => _events;

  void setEvents(List<calendar.Event> events) {
    _events = events;
    notifyListeners();
  }

  void clearEvents() {
    _events = [];
    notifyListeners();
  }

  Future<void> loadEvents({
    required String accessToken,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startDate,
        endTime: endDate,
      );
      setEvents(events);
      print("Events loaded successfully.");
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  Future<void> createEvent({
    required String accessToken,
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? location,
    required String locationName,
    DateTime? recurrenceEndDate,
    required RecurrenceType recurrenceType,
    required String priority,
  }) async {
    try {
      await GoogleCalendarService.createEvent(
        accessToken: accessToken,
        title: title,
        description: description,
        date: date,
        startTime: startTime,
        endTime: endTime,
        location: location,
        location_name: locationName,
        recurrenceEndDate: recurrenceEndDate,
        recurrenceType: recurrenceType,
        priority: priority,
      );
      notifyListeners();
      print("Event created successfully.");
    } catch (e) {
      print("Error creating event: $e");
    }
  }

  Future<void> deleteEvent({
    required String accessToken,
    required String eventId,
    required bool deleteRecurrence,
  }) async {
    try {
      await GoogleCalendarService.deleteEvent(
        accessToken: accessToken,
        eventId: eventId,
        deleteRecurrence: deleteRecurrence,
      );
      _events.removeWhere((event) => event.id == eventId);
      notifyListeners();
      print("Event deleted successfully.");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<void> updateEvent({
    required String accessToken,
    required String eventId,
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required bool updateSeries,
    String? location,
    String? priority,
  }) async {
    try {
      await GoogleCalendarService.updateEvent(
        accessToken: accessToken,
        eventId: eventId,
        title: title,
        description: description,
        date: date,
        startTime: startTime,
        endTime: endTime,
        updateSeries: updateSeries,
        location: location,
        priority: priority,
      );
      notifyListeners();
      print("Event updated successfully.");
    } catch (e) {
      print("Error updating event: $e");
    }
  }
}
