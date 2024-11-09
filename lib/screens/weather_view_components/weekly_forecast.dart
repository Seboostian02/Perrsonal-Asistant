import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_card.dart';

class WeeklyForecast extends StatelessWidget {
  final Map<String, dynamic>? weeklyWeatherData;

  WeeklyForecast({required this.weeklyWeatherData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weeklyWeatherData!.entries.map((entry) {
          final date = entry.key;
          final dayWeather = entry.value;
          final formattedDate =
              DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(date));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: WeatherCard(
              date: formattedDate,
              maxTemperature:
                  dayWeather['temperature']['max']?.toString() ?? 'N/A',
              minTemperature:
                  dayWeather['temperature']['min']?.toString() ?? 'N/A',
              weatherCode:
                  dayWeather['weatherCode']['max']?.toString() ?? '1001',
            ),
          );
        }).toList(),
      ),
    );
  }
}
