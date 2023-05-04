import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/history.dart';
import 'package:weather_app/screens/settings.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import '../widgets/daily_weather.dart';
import '../widgets/weekly_weather_showcase.dart';

enum PermissionState {
  allowed,
  denied,
}

class Weather extends StatefulWidget {
  final bool locationPermission;

  const Weather({Key? key, required this.locationPermission}) : super(key: key);

  @override
  State<Weather> createState() => _FrontpageState();
}

class _FrontpageState extends State<Weather> {
  WeatherModel? _weatherModel;
  bool _isLocationEnabled = false;
  late final bool _locationPermission = widget.locationPermission;

  // @override
  // void initState() {
  //   super.initState();
  //   _getCurrentPosition();
  // }
  //
  // Future<void> _getCurrentPosition() async {
  //   // setState(() => _weatherModel = null);
  //   // _isLocationEnabled = await _handleLocationPermission();
  //   // setState(() {});
  //   if (!_isLocationEnabled) return;
  //   Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
  //       .then((Position position) {
  //     print(position);
  //     _getData(position);
  //   }).catchError((e) {
  //     debugPrint(e);
  //   });
  // }
  //
  // void _getData(Position position) {
  //   WeatherService.getWeatherByCoords(position).then((data) {
  //     setState(() {
  //       _weatherModel = data;
  //     });
  //   });
  // }

  Future<WeatherModel?> _getCurrentPositionWeather() async {
    // if (!_locationPermission) return null;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    WeatherModel? model = await WeatherService.getWeatherByCoords(pos);
    return model;
  }

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
    return FutureBuilder(
      future: _getCurrentPositionWeather(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print("hellooooo");
          // DailyWeather(
          //   locationPermission: _locationPermission,
            // data: snapshot.data,
          // );
        }
        return _loadingWeatherData;
      },
    );
  }
}
