import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_card.dart';

class HourlyForecast extends StatelessWidget {
  final Map<String, dynamic>? hourlyWeatherData;

  HourlyForecast({required this.hourlyWeatherData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: hourlyWeatherData!.keys.length,
      itemBuilder: (context, index) {
        final dateTime = hourlyWeatherData!.keys.elementAt(index);
        final hourWeather = hourlyWeatherData![dateTime];
        final formattedTime =
            DateFormat('HH:mm').format(DateTime.parse(dateTime));

        return WeatherCard(
          date: formattedTime,
          maxTemperature: hourWeather['temperature']?.toString() ?? 'N/A',
          minTemperature:
              hourWeather['temperatureApparent']?.toString() ?? 'N/A',
          weatherCode: hourWeather['weatherCode']?.toString() ?? '1001',
        );
      },
    );
  }
}
