import 'package:calendar/services/auth_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../services/google_calendar_service.dart';

class EventService {
  Future<List<calendar.Event>> fetchEvents() async {
    final String? accessToken = await AuthService().accessToken;
    List<calendar.Event> events = [];

    if (accessToken != null) {
      DateTime now = DateTime.now();
      DateTime startTime =
          now.subtract(const Duration(hours: 12)); // 12 ore în urma
      DateTime endTime =
          now.add(const Duration(days: 365 * 10)); // evenimente pe 10 ani

      events = await GoogleCalendarService.getEvents(
        accessToken: accessToken,
        startTime: startTime,
        endTime: endTime,
      );
    }

    return events;
  }
}
