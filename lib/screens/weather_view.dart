import 'package:flutter/material.dart';
import 'package:calendar/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

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
      print("Current weather data:");
      print(currentWeatherData);
      print("\nWeekly weather data:");
      print(weeklyWeatherData);
    } catch (e) {
      setState(() {
        isLoading = false;
        currentWeatherData = null;
        weeklyWeatherData = null;
      });
      print('Error while fetching weather data: $e');
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${currentWeatherData!['timelines']['minutely'][0]['values']['temperature']}°C',
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Cloudy with ${currentWeatherData!['timelines']['minutely'][0]['values']['precipitationProbability']}% chance of precipitation",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Wind: ${currentWeatherData!['timelines']['minutely'][0]['values']['windSpeed']} km/h',
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
                                    weatherIcons[
                                            currentWeatherData!['timelines']
                                                        ['minutely'][0]
                                                    ['values']['weatherCode']
                                                .toString()] ??
                                        Icons.error,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${currentWeatherData!['timelines']['minutely'][0]['values']['humidity']}% Humidity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                          Expanded(
                            child: ListView.builder(
                              itemCount: weeklyWeatherData!.keys.length,
                              itemBuilder: (context, index) {
                                final date =
                                    weeklyWeatherData!.keys.elementAt(index);
                                final dayWeather = weeklyWeatherData![date];
                                final formattedDate =
                                    DateFormat('EEEE, MMM d, yyyy')
                                        .format(DateTime.parse(date));

                                final weatherCode = dayWeather['weatherCode']
                                            ['max']
                                        ?.toString() ??
                                    '1001';

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
                                        Icon(
                                          weatherIcons[weatherCode] ??
                                              Icons.error,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
