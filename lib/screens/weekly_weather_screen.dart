import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

import '../widgets/weekly_weather.dart';

import '../models/weekly_weather_model.dart';

class WeeklyWeatherScreen extends StatelessWidget {
  final WeeklyWeatherModel weeklyWeatherModel;

  const WeeklyWeatherScreen({Key? key, required this.weeklyWeatherModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      resizeToAvoidBottomInset: false,
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF8EC5FC),
          Color(0xFFE0C3FC),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCB9FC),
        title: const Text("Weather companion"),
        centerTitle: true,
      ),
      body: WeeklyWeather(weeklyWeatherModel: weeklyWeatherModel),
    );
  }
}
