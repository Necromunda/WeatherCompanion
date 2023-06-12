import '/models/daily_weather_model.dart';
import '/models/weekly_weather_model.dart';

class CombinedWeatherModel {
  DailyWeatherModel? dailyWeatherModel;
  List<WeeklyWeatherModel>? weeklyWeatherModel;
  List<WeeklyWeatherModel>? parsedWeeklyWeatherModel;

  CombinedWeatherModel({
    this.dailyWeatherModel,
    this.weeklyWeatherModel,
    this.parsedWeeklyWeatherModel,
  });
}
