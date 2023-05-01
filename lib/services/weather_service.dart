import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const String apiKey = "361d62e05c932bca9c667b4ac45db37f";

  static Future<WeatherModel?> getWeatherByCity(String city) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&q=$city&APPID=$apiKey";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherModel? model =
          await WeatherModel.createWeatherModel(jsonDecode(response.body));
      return model;
    } else {
      print("Error getting weather data");
      return null;
    }
  }

  static Future<WeatherModel?> getWeatherByCoords(Position position) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherModel? model =
          await WeatherModel.createWeatherModel(jsonDecode(response.body));
      return model;
    } else {
      print("Error getting weather data");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getWeeklyWeatherByCoords(
      double lat, double lon) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/forecast?units=metric&lat=$lat&lon=$lon&appid=$apiKey";
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data["list"]);
      return null;
    } else {
      print("Error getting weather data");
      return null;
    }
  }

  static Future<Map<String, double>?> getCoordsByCity(String city) async {
    final String url =
        "http://api.openweathermap.org/geo/1.0/direct?q=$city&appid=$apiKey";
    // print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body[0]);
      // double lat = data["lat"];
      // double lon = data["lon"];
      print(response.body);
      return {"lat": data["lat"], "lon": data["lon"]};
    } else {
      print("Error getting coords by city");
      return null;
    }
  }
}
