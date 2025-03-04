import 'package:TimeBuddy/services/auth_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../services/google_calendar_service.dart';

class EventService {
  Future<List<calendar.Event>> fetchEvents() async {
    final String? accessToken = await AuthService().accessToken;
    List<calendar.Event> events = [];

    if (accessToken != null) {
      DateTime now = DateTime.now();
      DateTime startTime = now.subtract(const Duration(hours: 12));
      DateTime endTime = now.add(const Duration(days: 365 * 10));

      events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );
    }

    return events;
  }

  calendar.Event createNonNullEvent(calendar.Event? event) {
    return calendar.Event(
      summary: event?.summary ?? "No Title",
      location: event?.location ?? "No Location",
      description: event?.description ?? "No Description",
      start: event?.start ?? calendar.EventDateTime(dateTime: DateTime.now()),
      end: event?.end ??
          calendar.EventDateTime(
              dateTime: DateTime.now().add(const Duration(hours: 1))),
    );
  }
}
