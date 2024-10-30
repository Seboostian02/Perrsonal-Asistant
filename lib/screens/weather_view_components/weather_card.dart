import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherCard extends StatelessWidget {
  final String date;
  final String maxTemperature;
  final String minTemperature;
  final String weatherCode;

  WeatherCard({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, IconData> weatherIcons = {
      "1000": WeatherIcons.day_sunny,
      "1100": WeatherIcons.day_sunny_overcast,
      "1101": WeatherIcons.day_cloudy,
      "1102": WeatherIcons.day_cloudy,
      "1001": WeatherIcons.cloudy,
      "2000": WeatherIcons.fog,
      "2100": WeatherIcons.fog,
      "4000": WeatherIcons.rain_mix,
      "4001": WeatherIcons.rain,
      "4200": WeatherIcons.rain,
      "4201": WeatherIcons.rain,
      "5000": WeatherIcons.snow,
      "5001": WeatherIcons.snow,
      "5100": WeatherIcons.snow,
      "5101": WeatherIcons.snow,
      "6000": WeatherIcons.rain,
      "6001": WeatherIcons.rain,
      "6200": WeatherIcons.rain,
      "6201": WeatherIcons.rain,
      "7000": WeatherIcons.snow,
      "7101": WeatherIcons.snow,
      "7102": WeatherIcons.snow,
      "8000": WeatherIcons.thunderstorm,
    };

    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$maxTemperature° / $minTemperature°C',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              weatherIcons[weatherCode] ?? Icons.error,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
