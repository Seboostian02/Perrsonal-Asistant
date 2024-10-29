import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

class CurrentWeather extends StatelessWidget {
  final Map<String, dynamic>? weatherData;

  CurrentWeather({required this.weatherData});

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weatherData!['timelines']['minutely'][0]['values']['temperature']}°C',
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Cloudy with ${weatherData!['timelines']['minutely'][0]['values']['precipitationProbability']}% chance of precipitation",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Wind: ${weatherData!['timelines']['minutely'][0]['values']['windSpeed']} km/h',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Icon(
              weatherIcons[weatherData!['timelines']['minutely'][0]['values']
                          ['weatherCode']
                      .toString()] ??
                  Icons.error,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              '${weatherData!['timelines']['minutely'][0]['values']['humidity']}% Humidity',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
