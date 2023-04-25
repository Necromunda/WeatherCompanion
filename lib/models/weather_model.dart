import 'package:intl/intl.dart';

class WeatherModel {
  double? lat,
      lon,
      temp,
      tempFeelsLike,
      tempMin,
      tempMax,
      windSpeed,
      pressure,
      humidity,
      visibility,
      windDeg;

  // int? pressure, humidity, visibility, windDeg;
  String? weatherType,
      weatherTypeDescription,
      icon,
      city,
      countryCode,
      sunrise,
      sunset,
      iconUrl;

  WeatherModel({
    this.lat,
    this.lon,
    this.temp,
    this.tempFeelsLike,
    this.tempMin,
    this.tempMax,
    this.windSpeed,
    this.windDeg,
    this.sunrise,
    this.sunset,
    this.pressure,
    this.humidity,
    this.visibility,
    this.weatherType,
    this.weatherTypeDescription,
    this.icon,
    this.city,
    this.countryCode,
    this.iconUrl,
  });

  static Future<WeatherModel?> createWeatherModel(
      final Map<String, dynamic> data) async {
    DateTime sunr =
        DateTime.fromMillisecondsSinceEpoch(data["sys"]["sunrise"] * 1000);
    DateTime suns =
        DateTime.fromMillisecondsSinceEpoch(data["sys"]["sunset"] * 1000);
    print(data["wind"]["deg"]);

    try {
      return WeatherModel(
        lat: data["coord"]["lat"].toDouble(),
        lon: data["coord"]["lon"].toDouble(),
        weatherType: data["weather"][0]["main"],
        weatherTypeDescription: data["weather"][0]["description"],
        icon: data["weather"][0]["icon"],
        temp: data["main"]["temp"].toDouble(),
        tempFeelsLike: data["main"]["feels_like"].toDouble(),
        tempMin: data["main"]["temp_min"].toDouble(),
        tempMax: data["main"]["temp_max"].toDouble(),
        pressure: data["main"]["pressure"].toDouble(),
        humidity: data["main"]["humidity"].toDouble(),
        visibility: data["visibility"].toDouble(),
        windSpeed: data["wind"]["speed"].toDouble(),
        windDeg: data["wind"]["deg"].toDouble(),
        countryCode: data["sys"]["country"],
        sunrise: DateFormat("HH:mm").format(sunr),
        sunset: DateFormat("HH:mm").format(suns),
        city: data["name"],
        iconUrl:
            "https://openweathermap.org/img/wn/${data["weather"][0]["icon"]}@2x.png",
      );
    } catch (e) {
      print(e);
      return null;
    }
  }
}
