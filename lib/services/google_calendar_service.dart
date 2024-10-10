import 'package:calendar/services/auth_service.dart';
import 'package:googleapis_auth/googleapis_auth.dart';

import 'package:googleapis/calendar/v3.dart' as calendar;

import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  static Future<void> createEvent({
    required String accessToken,
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    try {
      String? accessToken = await AuthService().accessToken;

      if (accessToken != null) {
        final client = await getAuthenticatedClient(accessToken);
        var calendarApi = calendar.CalendarApi(client);

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

        await calendarApi.events.insert(event, "primary");
        print("Event created successfully!");
      } else {
        print("Failed to get access token for Google Calendar");
      }
    } catch (e) {
      print("Error creating event: $e");
    }
  }

  static Future<AuthClient> getAuthenticatedClient(String accessToken) async {
    final accessCredentials = AccessCredentials(
      AccessToken('Bearer', accessToken,
          DateTime.now().add(Duration(hours: 1)).toUtc()),
      null,
      ['https://www.googleapis.com/auth/calendar'],
    );

    return authenticatedClient(http.Client(), accessCredentials);
  }
}
