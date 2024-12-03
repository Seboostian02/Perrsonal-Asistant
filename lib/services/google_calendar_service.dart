import 'package:calendar/widgets/event_form.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'notification_service.dart';

final NotificationService notificationService = NotificationService();

class GoogleCalendarService {
  static Future<void> createEvent({
    required String accessToken,
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? location,
    required String location_name,
    DateTime? recurrenceEndDate,
    required RecurrenceType recurrenceType,
    required String priority,
  }) async {
    try {
      final client = await getAuthenticatedClient(accessToken);
      var calendarApi = calendar.CalendarApi(client);

      var event = calendar.Event();
      event.summary = title;
      event.description = description;
      event.location = location;

      event.extendedProperties =
          calendar.EventExtendedProperties(private: {'priority': priority});
      var startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      ).toUtc();

      var endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      ).toUtc();

      event.start = calendar.EventDateTime(
        dateTime: startDateTime,
        timeZone: 'Europe/Bucharest',
      );

      event.end = calendar.EventDateTime(
        dateTime: endDateTime,
        timeZone: 'Europe/Bucharest',
      );

      if (recurrenceType != RecurrenceType.none) {
        String rrule = 'RRULE:';
        if (recurrenceType == RecurrenceType.daily) {
          rrule += 'FREQ=DAILY';
        } else if (recurrenceType == RecurrenceType.weekly) {
          rrule += 'FREQ=WEEKLY';
        } else if (recurrenceType == RecurrenceType.monthly) {
          rrule += 'FREQ=MONTHLY';
        }
        if (recurrenceEndDate != null) {
          rrule +=
              ';UNTIL=${recurrenceEndDate.toUtc().toIso8601String().replaceAll('-', '').split('T').first}';
        }
        event.recurrence = [rrule];
      }

      var createdEvent = await calendarApi.events.insert(event, "primary");

      print("---------------");
      print("Event created successfully!");
    } catch (e) {
      print("Error creating event: $e");
    }
  }

  static Future<AuthClient> getAuthenticatedClient(String accessToken) async {
    final accessCredentials = AccessCredentials(
      AccessToken('Bearer', accessToken,
          DateTime.now().add(const Duration(hours: 1)).toUtc()),
      null,
      ['https://www.googleapis.com/auth/calendar'],
    );

    return authenticatedClient(http.Client(), accessCredentials);
  }

  static Future<List<calendar.Event>> getEvents({
    required String accessToken,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final client = await getAuthenticatedClient(accessToken);
      var calendarApi = calendar.CalendarApi(client);

      var events = await calendarApi.events.list(
        'primary',
        timeMin: startTime.toUtc(),
        timeMax: endTime.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  static Future<void> deleteEvent({
    required String accessToken,
    required String eventId,
    required bool deleteRecurrence,
  }) async {
    try {
      final client = await getAuthenticatedClient(accessToken);
      var calendarApi = calendar.CalendarApi(client);

      String mainEventId = eventId.split('_')[0];

      if (deleteRecurrence) {
        List<String> recurringEventIds = await getRecurringEventIds(
          calendarApi,
          accessToken,
          eventId,
        );

        for (String id in recurringEventIds) {
          if (id.startsWith(mainEventId)) {
            print("Attempting to delete recurring event: $id");
            try {
              await calendarApi.events.delete("primary", id);
              print("Recurring event removed: $id");
            } catch (e) {
              print("Failed to delete recurring event: $id - Error: $e");
            }
          }
        }
        print("Recurring event streak successfully removed!");
      } else {
        await calendarApi.events.delete("primary", eventId);
        print("The event was successfully removed!");
      }
    } catch (e) {
      print("Error deleting the event: $e");
    }
  }

  static Future<List<String>> getRecurringEventIds(
      calendar.CalendarApi calendarApi,
      String mainEventId,
      String eventId) async {
    List<String> recurringEventIds = [];
    String? pageToken;

    do {
      var events = await calendarApi.events.list(
        'primary',
        pageToken: pageToken,
      );

      for (var event in events.items!) {
        if (event.id != mainEventId &&
            event.recurrence != null &&
            event.recurrence!.isNotEmpty) {
          recurringEventIds.add(event.id!);
        }
      }

      pageToken = events.nextPageToken;
    } while (pageToken != null);

    print("Recurring event IDs found: $recurringEventIds");
    return recurringEventIds;
  }

  static Future<void> updateEvent({
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
      final client = await getAuthenticatedClient(accessToken);
      var calendarApi = calendar.CalendarApi(client);

      String mainEventId = eventId.split('_')[0];
      var event = await calendarApi.events.get("primary", mainEventId);

      // Actualizează detaliile principale ale seriei
      event.summary = title;
      event.description = description;
      event.location = location;

      if (priority != null) {
        event.extendedProperties ??=
            calendar.EventExtendedProperties(private: {});
        event.extendedProperties!.private!['priority'] = priority;
      }

      var startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      ).toUtc();

      var endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      ).toUtc();

      event.start = calendar.EventDateTime(
        dateTime: startDateTime,
        timeZone: 'Europe/Bucharest',
      );

      event.end = calendar.EventDateTime(
        dateTime: endDateTime,
        timeZone: 'Europe/Bucharest',
      );

      if (updateSeries) {
        // Obține toate instanțele seriei
        var instances =
            await calendarApi.events.instances("primary", mainEventId);
        var instanceList = instances.items ?? [];

        // Actualizează evenimentul principal
        await calendarApi.events.patch(event, "primary", mainEventId);
        print("Recurring series updated successfully!");

        // Actualizează fiecare instanță cu noile informații
        for (var instance in instanceList) {
          instance.summary = title;
          instance.description = description;
          instance.location = location;

          if (priority != null) {
            instance.extendedProperties ??=
                calendar.EventExtendedProperties(private: {});
            instance.extendedProperties!.private!['priority'] = priority;
          }

          var instanceStart = DateTime(
            instance.start!.dateTime!.year,
            instance.start!.dateTime!.month,
            instance.start!.dateTime!.day,
            instance.start!.dateTime!.hour,
            instance.start!.dateTime!.minute,
          ).toUtc();

          var instanceEnd = DateTime(
            instance.end!.dateTime!.year,
            instance.end!.dateTime!.month,
            instance.end!.dateTime!.day,
            instance.end!.dateTime!.hour,
            instance.end!.dateTime!.minute,
          ).toUtc();

          instance.start = calendar.EventDateTime(
            dateTime: instanceStart,
            timeZone: 'Europe/Bucharest',
          );

          instance.end = calendar.EventDateTime(
            dateTime: instanceEnd,
            timeZone: 'Europe/Bucharest',
          );

          // Actualizează instanța în calendar
          try {
            await calendarApi.events.patch(instance, "primary", instance.id!);
            print("Updated instance: ${instance.id}");
          } catch (e) {
            print("Failed to update instance: ${instance.id} - Error: $e");
          }
        }
      } else {
        // Actualizează doar instanța curentă
        await calendarApi.events.patch(event, "primary", eventId);
        print("Single instance updated successfully!");
      }
    } catch (e) {
      print("Error updating event: $e");
    }
  }
}
