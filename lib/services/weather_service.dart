import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const String apiKey = "361d62e05c932bca9c667b4ac45db37f";

  static Future<DailyWeatherModel?> getWeatherByCity(String city) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&q=$city&APPID=$apiKey";
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        DailyWeatherModel? model =
            await DailyWeatherModel.createWeatherModel(jsonDecode(response.body));
        return model;
      } else {
        print("Error getting weather data");
        return null;
      }
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
  }

  static Future<DailyWeatherModel?> getWeatherByCoords(Position position) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        DailyWeatherModel? model =
            await DailyWeatherModel.createWeatherModel(jsonDecode(response.body));
        return model;
      } else {
        print("Error getting weather data");
        return null;
      }
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
  }

  static Future<String?> getCityByCoords(Position position) async {
    final String url =
        "http://api.openweathermap.org/geo/1.0/reverse?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey";
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body)[0];
        return "${data["name"]}, ${data["country"]}";
      } else {
        print("Error getting city name by coords");
        return null;
      }
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
  }

  // static Future<List<Map<String, dynamic>>?> getWeeklyWeatherByCoords(
  static Future<List<dynamic>?> getWeeklyWeatherByCoords(
      double lat, double lon) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/forecast?units=metric&lat=$lat&lon=$lon&appid=$apiKey";
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["list"];
      } else {
        print("Error getting weather data");
        return null;
      }
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
  }

  static Future<Map<String, double>?> getCoordsByCity(String city) async {
    final String url =
        "http://api.openweathermap.org/geo/1.0/direct?q=$city&appid=$apiKey";
    print(url);
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) return null;
        print("hello");
        return {"lat": data[0]["lat"], "lon": data[0]["lon"]};
      } else {
        print("Error getting coords by city");
        return null;
      }
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
  }
}
