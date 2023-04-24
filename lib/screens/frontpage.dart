import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/daily_weather.dart';
import '../widgets/weekly_weather.dart';

class Frontpage extends StatefulWidget {
  const Frontpage({Key? key}) : super(key: key);

  @override
  State<Frontpage> createState() => _FrontpageState();
}

class _FrontpageState extends State<Frontpage> {
  WeatherModel? _weatherModel;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  void _initPlatformState() => _getData();

  _currentLocationButtonHandler() => null;

  void _refreshButtonHandler() => _getData();

  void _searchButtonHandler() async {
    String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&q=Oulu,fi&APPID=${WeatherService.apiKey}";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherModel.createWeatherModel(jsonDecode(response.body))
          .then((model) async {
        setState(() {
          _weatherModel = model;
        });
      });
    } else {
      print("Error getting weather data");
    }
  }

  void _getData() async {
    WeatherService.getWeather().then((data) async {
      WeatherModel.createWeatherModel(data).then((model) async {
        setState(() {
          _weatherModel = model;
        });

        print(
            "Weather for ${_weatherModel!.city}, ${_weatherModel!.countryCode}\nSunrise at ${_weatherModel!.sunrise}\nSunset at ${_weatherModel!.sunset}");
      });
    });
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
            child: _weatherModel == null
                ? const Center(
                    child: Text("Loading weather data"),
                  )
                : DailyWeather(weatherModel: _weatherModel!),
          ),
          Expanded(
            child: WeeklyWeather(weatherModel: _weatherModel),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _currentLocationButtonHandler,
            tooltip: "Current location",
            child: const Icon(Icons.my_location_outlined),
          ),
          FloatingActionButton(
            onPressed: _refreshButtonHandler,
            tooltip: "Refresh",
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: _searchButtonHandler,
            tooltip: "Select location",
            child: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
