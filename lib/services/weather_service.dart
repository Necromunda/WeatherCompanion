import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const String apiKey = "361d62e05c932bca9c667b4ac45db37f";
  static const Map<String, dynamic> _weatherData = {
    "coord": {"lon": 25.4682, "lat": 65.0124},
    "weather": [
      {
        "id": 803,
        "main": "Clouds",
        "description": "broken clouds",
        "icon": "04d"
      }
    ],
    "base": "stations",
    "main": {
      "temp": 2.43,
      "feels_like": -1.95,
      "temp_min": 2.06,
      "temp_max": 2.9,
      "pressure": 1008,
      "humidity": 65
    },
    "visibility": 10000,
    "wind": {"speed": 5.14, "deg": 60},
    "clouds": {"all": 75},
    "dt": 1682342244,
    "sys": {
      "type": 2,
      "id": 2003583,
      "country": "FI",
      "sunrise": 1682302247,
      "sunset": 1682360494
    },
    "timezone": 10800,
    "id": 643492,
    "name": "Oulu",
    "cod": 200
  };

  static Future<WeatherModel?> getWeatherByCity(String city) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&q=$city&APPID=$apiKey";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherModel? model = await WeatherModel.createWeatherModel(jsonDecode(response.body));
      return model;
    } else {
      print("Error getting weather data");
      return null;
    }
  }

  static Future<WeatherModel?> getWeatherByCoords(Position position) async {
    final String url =
        "http://api.openweathermap.org/data/2.5/weather?units=metric&lat=${position.latitude}&lon=${position.longitude}&APPID=$apiKey";
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherModel? model = await WeatherModel.createWeatherModel(jsonDecode(response.body));
      return model;
    } else {
      print("Error getting weather data");
      return null;
    }
  }
}
