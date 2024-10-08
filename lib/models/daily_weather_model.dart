class DailyWeatherModel {
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

  String? weatherType, weatherTypeDescription, icon, city, countryCode, iconUrl;

  DateTime? sunrise, sunset, dt;

  bool isFavorite;

  DailyWeatherModel({
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
    this.dt,
    required this.isFavorite,
  });

  String get currentCity => "$city, $countryCode";

  static Future<DailyWeatherModel?> createWeatherModel(
      final Map<String, dynamic> data) async {
    try {
      DateTime sunr =
          DateTime.fromMillisecondsSinceEpoch(data["sys"]["sunrise"] * 1000);
      DateTime suns =
          DateTime.fromMillisecondsSinceEpoch(data["sys"]["sunset"] * 1000);
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(data["dt"] * 1000);

      return DailyWeatherModel(
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
        sunrise: sunr,
        sunset: suns,
        city: data["name"],
        iconUrl:
            "https://openweathermap.org/img/wn/${data["weather"][0]["icon"]}@2x.png",
        dt: dt,
        isFavorite: false,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lon": lon,
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
      "countryCode": countryCode,
      "sunrise": sunrise,
      "sunset": sunset,
      "city": city,
      "iconUrl": iconUrl,
      "dt": dt,
      "isFavorite": isFavorite,
    };
  }
}
