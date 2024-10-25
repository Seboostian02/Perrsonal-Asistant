import 'dart:convert';
import 'package:calendar/env/env.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = Env.weatherKey;
  final String forecastBaseUrl = 'https://api.tomorrow.io/v4/weather/forecast';

  Future<Map<String, dynamic>?> getWeather(String location) async {
    final response = await http.get(
      Uri.parse('$forecastBaseUrl?location=$location&apikey=$apiKey'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>?> getWeeklyWeather(String location) async {
    final response = await http.get(
      Uri.parse(
          '$forecastBaseUrl?location=$location&apikey=$apiKey&timesteps=1d&units=metric'),
      headers: {'accept': 'application/json'},
    );

    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['timelines'] != null && data['timelines']['daily'] != null) {
        Map<String, dynamic> weeklyForecast = {};

        for (var day in data['timelines']['daily']) {
          final date = day['time'];
          weeklyForecast[date] = {
            'temperature': {
              'max': day['values']['temperatureMax'],
              'min': day['values']['temperatureMin'],
            },
            'weather_descriptions': day['values']['weatherCode'],
          };
        }
        return weeklyForecast;
      }
      throw Exception('Weekly forecast data is not available');
    } else {
      throw Exception('Failed to load weekly weather data');
    }
  }
}
