import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_card.dart';

class WeeklyForecast extends StatefulWidget {
  final Map<String, dynamic>? weeklyWeatherData;

  WeeklyForecast({required this.weeklyWeatherData});

  @override
  _WeeklyForecastState createState() => _WeeklyForecastState();
}

class _WeeklyForecastState extends State<WeeklyForecast> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(50.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      itemCount: widget.weeklyWeatherData!.keys.length,
      itemBuilder: (context, index) {
        final date = widget.weeklyWeatherData!.keys.elementAt(index);
        final dayWeather = widget.weeklyWeatherData![date];
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
