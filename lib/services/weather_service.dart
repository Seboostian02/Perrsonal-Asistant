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

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['timelines'] != null && data['timelines']['daily'] != null) {
        Map<String, dynamic> weeklyForecast = {};

        for (var day in data['timelines']['daily']) {
          final date = day['time'];
          final values = day['values'];

          weeklyForecast[date] = {
            'temperature': {
              'avg': values['temperatureAvg'],
              'max': values['temperatureMax'],
              'min': values['temperatureMin'],
            },
            'temperatureApparent': {
              'avg': values['temperatureApparentAvg'],
              'max': values['temperatureApparentMax'],
              'min': values['temperatureApparentMin'],
            },
            'cloudCover': {
              'avg': values['cloudCoverAvg'],
              'max': values['cloudCoverMax'],
              'min': values['cloudCoverMin'],
            },
            'humidity': {
              'avg': values['humidityAvg'],
              'max': values['humidityMax'],
              'min': values['humidityMin'],
            },
            'precipitationProbability': {
              'avg': values['precipitationProbabilityAvg'],
              'max': values['precipitationProbabilityMax'],
              'min': values['precipitationProbabilityMin'],
            },
            'pressureSurfaceLevel': {
              'avg': values['pressureSurfaceLevelAvg'],
              'max': values['pressureSurfaceLevelMax'],
              'min': values['pressureSurfaceLevelMin'],
            },
            'wind': {
              'speedAvg': values['windSpeedAvg'],
              'speedMax': values['windSpeedMax'],
              'speedMin': values['windSpeedMin'],
              'gustAvg': values['windGustAvg'],
              'gustMax': values['windGustMax'],
              'gustMin': values['windGustMin'],
              'directionAvg': values['windDirectionAvg'],
            },
            'uvIndex': {
              'avg': values['uvIndexAvg'],
              'max': values['uvIndexMax'],
              'min': values['uvIndexMin'],
            },
            'sunriseTime': values['sunriseTime'],
            'sunsetTime': values['sunsetTime'],
            'moonriseTime': values['moonriseTime'],
            'moonsetTime': values['moonsetTime'],
            'visibility': {
              'avg': values['visibilityAvg'],
              'max': values['visibilityMax'],
              'min': values['visibilityMin'],
            },
            'weatherCode': {
              'max': values['weatherCodeMax'],
              'min': values['weatherCodeMin'],
            },
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
