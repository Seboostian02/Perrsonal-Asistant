import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_card.dart';

class WeeklyForecast extends StatelessWidget {
  final Map<String, dynamic>? weeklyWeatherData;

  WeeklyForecast({required this.weeklyWeatherData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: weeklyWeatherData!.keys.length,
      itemBuilder: (context, index) {
        final date = weeklyWeatherData!.keys.elementAt(index);
        final dayWeather = weeklyWeatherData![date];
        final formattedDate =
            DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(date));

        return WeatherCard(
          date: formattedDate,
          maxTemperature: dayWeather['temperature']['max']?.toString() ?? 'N/A',
          minTemperature: dayWeather['temperature']['min']?.toString() ?? 'N/A',
          weatherCode: dayWeather['weatherCode']['max']?.toString() ?? '1001',
        );
      },
    );
  }
}
