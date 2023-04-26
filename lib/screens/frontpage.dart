import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import '../widgets/daily_weather.dart';
import '../widgets/weekly_weather.dart';

enum PermissionState {
  allowed,
  denied,
}

class Frontpage extends StatefulWidget {
  const Frontpage({Key? key}) : super(key: key);

  @override
  State<Frontpage> createState() => _FrontpageState();
}

class _FrontpageState extends State<Frontpage> {
  WeatherModel? _weatherModel;
  Position? _currentPosition;
  PermissionState _permissionState = PermissionState.denied;
  final Position _kOulu = Position(
      longitude: 25.473821,
      latitude: 65.060823,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  @override
  void initState() {
    super.initState();
    // _initPlatformState();
    _getCurrentPosition();
  }

  // void _initPlatformState() async {
  //   _getCurrentPosition();
  // }

  Future<void> _getCurrentPosition() async {
    setState(() => _weatherModel = null);
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      print(position);
      _getData(position);
      // setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  void _refreshButtonHandler() => _getCurrentPosition();

  // Future<void> _requestPermission(BuildContext context, Function fn) async {
  //   const Permission locationPermission = Permission.location;
  //   bool locationStatus = false;
  //   bool isPermanentlyDenied = await locationPermission.isPermanentlyDenied;
  //   if (isPermanentlyDenied) {
  //     await openAppSettings();
  //   } else {
  //     var location_statu = await locationPermission.request();
  //     location_status = location_statu.isGranted;
  //     print(location_status);
  //   }
  // }

  void _getData(Position position) async {
    WeatherService.getWeatherByCoords(position).then((data) async {
      setState(() {
        _weatherModel = data;
      });
    });
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
              // backgroundColor: Colors.black,
              // pathBackgroundColor: Colors.black
            ),
          ),
          Text("Loading weather data"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
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
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: _weatherModel == null
                ? Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.red)),
                    child: _loadingWeatherData,
                  )
                : Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.red)),
                    child: DailyWeather(weatherModel: _weatherModel!),
                  ),
          ),
          Expanded(
            // flex: 3,
            child: WeeklyWeather(weatherModel: _weatherModel),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _refreshButtonHandler,
            tooltip: "Refresh",
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: () => _getData(_kOulu),
            tooltip: "Current",
            child: const Icon(Icons.location_searching),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
