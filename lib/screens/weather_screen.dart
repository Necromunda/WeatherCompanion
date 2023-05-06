import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/screens/history_screen.dart';
import 'package:weather_app/screens/settings_screen.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import '../models/weekly_weather_model.dart';
import '../widgets/daily_weather.dart';
import '../widgets/weekly_weather_showcase.dart';

enum PermissionState {
  allowed,
  denied,
}

class WeatherScreen extends StatefulWidget {
  final bool locationPermission;
  final Function addPreviousSearch;

  const WeatherScreen(
      {Key? key,
      required this.locationPermission,
      required this.addPreviousSearch})
      : super(key: key);

  @override
  State<WeatherScreen> createState() => _FrontpageState();
}

class _FrontpageState extends State<WeatherScreen>
    with AutomaticKeepAliveClientMixin<WeatherScreen> {
  late final bool _locationPermission = widget.locationPermission;
  late final Function _addPreviousSearch = widget.addPreviousSearch;
  DailyWeatherModel? _weatherModel = null;
  List<WeeklyWeatherModel>? _weeklyWeather = null;

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    // _initPlatformState();
    print("weather_screen initstate");
  }

  // void _initPlatformState() {
  //   if (_locationPermission) {
  // _getCurrentPositionWeather();
  // }
  // }

  Future<Map<String, dynamic>?> _getCurrentPositionWeather() async {
    if (!_locationPermission) return null;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    DailyWeatherModel? model = await WeatherService.getWeatherByCoords(pos);
    // if (model == null) return null;

    final List<dynamic>? weeklyWeatherData =
        await WeatherService.getWeeklyWeatherByCoords(
            pos.latitude, pos.longitude);
    // if (weeklyWeatherData == null) return null;

    // setState(() {
    _weatherModel = model;
    _weeklyWeather = _parseWeekData(weeklyWeatherData);
    // });
    if (_weatherModel != null) {
      widget.addPreviousSearch({
        "name": _weatherModel!.currentCity,
        "temp": _weatherModel!.temp,
        "date": DateTime.now(),
      });
    }
    return {"daily": _weatherModel, "weekly": _weeklyWeather};
  }

  List<WeeklyWeatherModel>? _parseWeekData(List<dynamic>? data) {
    if (data == null) return null;
    try {
      List<WeeklyWeatherModel> parsedDates = [];

      for (final obj in data) {
        DateTime dt = DateTime.parse(obj["dt_txt"]);
        if (dt.hour == 12 && dt.day != DateTime.now().day) {
          WeeklyWeatherModel.createWeeklyWeatherModel(obj)
              .then((value) => parsedDates.add(value!));
        }
      }
      if (parsedDates.length < 4 && parsedDates.isNotEmpty) {
        WeeklyWeatherModel.createWeeklyWeatherModel(data.last)
            .then((value) => parsedDates.add(value!));
      }
      return parsedDates;
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
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
    super.build(context);

    return FutureBuilder(
      future: _getCurrentPositionWeather(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Weather(
            locationPermission: _locationPermission,
            addPreviousSearch: _addPreviousSearch,
            // weatherModel: snapshot.data?["daily"],
            // weeklyWeatherModel: snapshot.data?["weekly"],
          );
        }
        return _loadingWeatherData;
      },
    );
  }
}
