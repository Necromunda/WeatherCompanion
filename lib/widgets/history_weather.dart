import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/daily_weather_model.dart';
import 'package:weather_app/models/weekly_weather_model.dart';
import 'package:weather_app/widgets/sun_times.dart';
import 'package:weather_app/widgets/weather_info_card.dart';
import 'package:weather_app/widgets/weather_temps.dart';
import 'package:weather_app/widgets/weekly_weather_showcase.dart';

class HistoryWeather extends StatelessWidget {
  final DailyWeatherModel dailyWeatherModel;
  final List<WeeklyWeatherModel> weeklyWeatherModelsList;

  const HistoryWeather({
    Key? key,
    required this.dailyWeatherModel,
    required this.weeklyWeatherModelsList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("rebuilding daily weather");

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 3.0),
                            bottom: BorderSide(color: Colors.black, width: 3.0),
                          ),
                        ),
                        child: Text(
                          dailyWeatherModel.currentCity,
                          style: TextStyle(
                              fontSize: dailyWeatherModel
                                          .currentCity.characters.length <=
                                      15
                                  ? 35
                                  : 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      DateFormat.MMMMEEEEd().format(dailyWeatherModel.dt!),
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  WeatherTemperature(
                    temp: dailyWeatherModel.temp!,
                    tempFeelsLike: dailyWeatherModel.tempFeelsLike!,
                    tempMin: dailyWeatherModel.tempMin!,
                    tempMax: dailyWeatherModel.tempMax!,
                  ),
                  WeatherInfoCard(
                    iconUrl: dailyWeatherModel.iconUrl!,
                    weatherTypeDescription:
                        dailyWeatherModel.weatherTypeDescription!,
                    visibility: dailyWeatherModel.visibility!,
                    humidity: dailyWeatherModel.humidity!,
                    pressure: dailyWeatherModel.pressure!,
                    windDeg: dailyWeatherModel.windDeg!,
                  ),
                  SunTimes(weatherModel: dailyWeatherModel),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: WeeklyWeatherShowcase(
            weeklyWeather: weeklyWeatherModelsList,
          ),
        ),
      ],
    );
  }
}
