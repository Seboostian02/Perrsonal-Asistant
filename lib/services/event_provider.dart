import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

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
}
