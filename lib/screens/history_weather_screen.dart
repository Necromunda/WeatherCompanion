import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:weather_app/widgets/history_weather.dart';

import '../models/weather_model.dart';

class HistoryWeatherScreen extends StatelessWidget {
  final DailyWeatherModel dailyWeatherModel;

  const HistoryWeatherScreen({Key? key, required this.dailyWeatherModel}) : super(key: key);

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
      body: HistoryWeather(dailyWeatherModel: dailyWeatherModel),
    );
  }
}