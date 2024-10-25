import 'package:flutter/material.dart';
import 'package:calendar/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

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
    try {
      final lat = widget.location.latitude;
      final lon = widget.location.longitude;

      final locationString = '$lat,$lon';
      final currentWeather = await weatherService.getWeather(locationString);
      final weeklyWeather =
          await weatherService.getWeeklyWeather(locationString);
      print("weekly weather----------------");
      print(weeklyWeather);
      setState(() {
        currentWeatherData = currentWeather;
        weeklyWeatherData = weeklyWeather;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    padding: EdgeInsets.all(16.0),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentWeatherData!['timelines']['daily'][0]['values']['temperatureAvg']?.toString() ?? 'N/A'}°C',
                                  style: const TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  currentWeatherData!['timelines']['daily'][0]
                                              ['values']['weatherCode']
                                          ?.toString() ??
                                      'N/A',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.wb_sunny,
                              size: 70,
                              color: Colors.yellowAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'Weekly Forecast',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: weeklyWeatherData!.keys.length,
                            itemBuilder: (context, index) {
                              final date =
                                  weeklyWeatherData!.keys.elementAt(index);
                              final dayWeather = weeklyWeatherData![date];

                              final formattedDate = DateFormat('MMM d, yyyy')
                                  .format(DateTime.parse(date));

                              return Card(
                                color: Colors.white.withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${dayWeather['temperature']['max']?.toString() ?? 'N/A'}° / ${dayWeather['temperature']['min']?.toString() ?? 'N/A'}°C',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.cloud,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'Failed to load weather data',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
      ),
    );
  }
}
