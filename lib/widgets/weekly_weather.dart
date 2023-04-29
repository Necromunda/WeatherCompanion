import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class WeeklyWeather extends StatefulWidget {
  final bool hasLocationPermission;

  const WeeklyWeather({Key? key, required this.hasLocationPermission}) : super(key: key);

  @override
  State<WeeklyWeather> createState() => _WeeklyWeatherState();
}

class _WeeklyWeatherState extends State<WeeklyWeather> {
  late final bool _hasLocationPermission = widget.hasLocationPermission;

  Widget get _loadingWeatherData {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 75,
            height: 75,
            child: LoadingIndicator(
              indicatorType: Indicator.ballRotateChase,
              colors: [Colors.white],
              strokeWidth: 2,
            ),
          ),
          Text("Loading weather data"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
      child: Center(
        child: Text("Weekly forecasts here ..."),
      ),
    );
  }
}
