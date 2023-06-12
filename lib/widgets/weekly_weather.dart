import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/combined_weather_model.dart';

import '/widgets/weather_info_card.dart';
import '/widgets/weather_temps.dart';

import '../models/weekly_weather_model.dart';

class WeeklyWeather extends StatelessWidget {
  final WeeklyWeatherModel weeklyWeatherModel;
  // final CombinedWeatherModel combinedWeatherModel;

  const WeeklyWeather({Key? key, required this.weeklyWeatherModel})
  // const WeeklyWeather({Key? key, required this.combinedWeatherModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  DateFormat.MMMMEEEEd().format(weeklyWeatherModel.dt!),
                  // DateFormat.MMMMEEEEd().format(combinedWeatherModel.weeklyWeatherModel!.dt!),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              Column(
                children: [
                  WeatherTemperature(
                    // combinedWeatherModel: combinedWeatherModel,
                    temp: weeklyWeatherModel.temp!,
                    tempFeelsLike: weeklyWeatherModel.tempFeelsLike!,
                    tempMin: weeklyWeatherModel.tempMin!,
                    tempMax: weeklyWeatherModel.tempMax!,
                  ),
                  WeatherInfoCard(
                    // combinedWeatherModel: combinedWeatherModel,
                    iconUrl: weeklyWeatherModel.iconUrl!,
                    weatherTypeDescription:
                        weeklyWeatherModel.weatherTypeDescription!,
                    visibility: weeklyWeatherModel.visibility!,
                    humidity: weeklyWeatherModel.humidity!,
                    pressure: weeklyWeatherModel.pressure!,
                    windDeg: weeklyWeatherModel.windDeg!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
