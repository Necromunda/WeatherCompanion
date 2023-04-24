import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';

class WeeklyWeather extends StatefulWidget {
  final WeatherModel? weatherModel;

  const WeeklyWeather({Key? key, required this.weatherModel}) : super(key: key);

  @override
  State<WeeklyWeather> createState() => _WeeklyWeatherState();
}

class _WeeklyWeatherState extends State<WeeklyWeather> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Weekly forecasts here ..."),);
  }
}
