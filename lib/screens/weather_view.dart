import 'package:calendar/screens/weather_view_components/current_weather.dart';
import 'package:calendar/screens/weather_view_components/weekly_forecast.dart';
import 'package:flutter/material.dart';
import 'package:calendar/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherView extends StatefulWidget {
  final Position location;

  WeatherView({required this.location});

  @override
  WeatherViewState createState() => WeatherViewState();
}

class WeatherViewState extends State<WeatherView> {
  WeatherService weatherService = WeatherService();
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? weeklyWeatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() => isLoading = true);
    try {
      final lat = widget.location.latitude;
      final lon = widget.location.longitude;
      final locationString = '$lat,$lon';

      final currentWeather = await weatherService.getWeather(locationString);
      final weeklyWeather =
          await weatherService.getWeeklyWeather(locationString);

      setState(() {
        currentWeatherData = currentWeather;
        weeklyWeatherData = weeklyWeather;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        currentWeatherData = null;
        weeklyWeatherData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchWeather,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : currentWeatherData != null && weeklyWeatherData != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Weather',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 15),
                          CurrentWeather(
                            weatherData: currentWeatherData,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Weekly Forecast',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 150,
                            child: WeeklyForecast(
                              weeklyWeatherData: weeklyWeatherData,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Failed to load weather data',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
        ),
      ),
    );
  }
}
