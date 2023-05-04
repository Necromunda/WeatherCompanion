import 'package:intl/intl.dart';

class WeeklyWeatherModel {
  double? temp,
      tempFeelsLike,
      tempMin,
      tempMax,
      windSpeed,
      pressure,
      humidity,
      visibility,
      windDeg;

  String? weatherType, weatherTypeDescription, icon, iconUrl, dayAbbr;

  DateTime? dt;

  WeeklyWeatherModel({
    this.temp,
    this.tempFeelsLike,
    this.tempMin,
    this.tempMax,
    this.windSpeed,
    this.windDeg,
    this.pressure,
    this.humidity,
    this.visibility,
    this.weatherType,
    this.weatherTypeDescription,
    this.icon,
    this.iconUrl,
    this.dayAbbr,
    this.dt,
  });

  static Future<WeeklyWeatherModel?> createWeeklyWeatherModel(
      final Map<String, dynamic> data) async {
    try {
      DateTime dt = DateTime.parse(data["dt_txt"]);

      return WeeklyWeatherModel(
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
        iconUrl:
            "https://openweathermap.org/img/wn/${data["weather"][0]["icon"]}@2x.png",
        dayAbbr: DateFormat.E().format(dt),
        dt: dt,
      );
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "weatherType": weatherType,
      "weatherTypeDescription": weatherTypeDescription,
      "icon": icon,
      "temp": temp,
      "tempFeelsLike": tempFeelsLike,
      "tempMin": tempMin,
      "tempMax": tempMax,
      "pressure": pressure,
      "humidity": humidity,
      "visibility": visibility,
      "windSpeed": windSpeed,
      "windDeg": windDeg,
      "iconUrl": iconUrl,
      "dayAbbr": dayAbbr,
      "dt": dt,
    };
  }
}
