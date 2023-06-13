import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/widgets/sun_times.dart';
import '/widgets/weather_info_card.dart';
import '/widgets/weather_temps.dart';
import '/widgets/weekly_weather_showcase.dart';

import '../models/combined_weather_model.dart';

class HistoryWeather extends StatelessWidget {
  // final DailyWeatherModel dailyWeatherModel;
  // final List<WeeklyWeatherModel> weeklyWeatherModelsList;
  final CombinedWeatherModel combinedWeatherModel;

  const HistoryWeather({
    Key? key,
    required this.combinedWeatherModel,
    // required this.dailyWeatherModel,
    // required this.weeklyWeatherModelsList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("rebuilding daily weather");

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
                          // dailyWeatherModel.currentCity,
                          combinedWeatherModel.dailyWeatherModel!.currentCity,
                          style: TextStyle(
                              fontSize: combinedWeatherModel.dailyWeatherModel!
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
                      DateFormat.MMMMEEEEd().format(combinedWeatherModel.dailyWeatherModel!.dt!),
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  WeatherTemperature(
                    // combinedWeatherModel: combinedWeatherModel,
                    temp: combinedWeatherModel.dailyWeatherModel!.temp!,
                    tempFeelsLike: combinedWeatherModel.dailyWeatherModel!.tempFeelsLike!,
                    tempMin: combinedWeatherModel.dailyWeatherModel!.tempMin!,
                    tempMax: combinedWeatherModel.dailyWeatherModel!.tempMax!,
                  ),
                  WeatherInfoCard(
                    // combinedWeatherModel: combinedWeatherModel,
                    iconUrl: combinedWeatherModel.dailyWeatherModel!.iconUrl!,
                    weatherTypeDescription:
                    combinedWeatherModel.dailyWeatherModel!.weatherTypeDescription!,
                    visibility: combinedWeatherModel.dailyWeatherModel!.visibility!,
                    humidity: combinedWeatherModel.dailyWeatherModel!.humidity!,
                    pressure: combinedWeatherModel.dailyWeatherModel!.pressure!,
                    windDeg: combinedWeatherModel.dailyWeatherModel!.windDeg!,
                    windSpeed: combinedWeatherModel.dailyWeatherModel!.windSpeed!,
                  ),
                  SunTimes(weatherModel: combinedWeatherModel.dailyWeatherModel!),
                  // SunTimes(combinedWeatherModel: combinedWeatherModel),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: WeeklyWeatherShowcase(
            // weeklyWeather: combinedWeatherModel.parsedWeeklyWeatherModel!,
            combinedWeatherModel: combinedWeatherModel,
          ),
        ),
      ],
    );
  }
}
