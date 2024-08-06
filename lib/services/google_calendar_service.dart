import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';

class GoogleCalendarService {
  static final _clientId = ClientId(
      "490602646023-q31pisialt5lqtvgcahcm1csbjv25ut6.apps.googleusercontent.com",
      null);
  static final _scopes = [calendar.CalendarApi.calendarScope];

  static Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    print("-----------Entered create event");

    await clientViaUserConsent(_clientId, _scopes, (url) {
      // Deschide URL-ul de autentificare în browserul utilizatorului
      print("Please go to the following URL and grant access: $url");
    }).then((AuthClient client) async {
      // Crearea instanței API Calendar
      var calendarApi = calendar.CalendarApi(client);

      // Crearea obiectului eveniment
      var event = calendar.Event();
      event.summary = title;
      event.description = description;

      var startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      var endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      event.start = calendar.EventDateTime(
        dateTime: startDateTime,
        timeZone: 'GMT+3',
      );

      event.end = calendar.EventDateTime(
        dateTime: endDateTime,
        timeZone: 'GMT+3',
      );

      // Adăugarea evenimentului în calendarul utilizatorului
      try {
        await calendarApi.events.insert(event, "primary");
        print("Event created successfully!");
      } catch (e) {
        print("Failed to create event: $e");
      } finally {
        client.close();
      }
    });
  }
}
