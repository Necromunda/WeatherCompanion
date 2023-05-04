import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widgets/weather_info_card.dart';
import 'package:weather_app/widgets/weather_temps.dart';

import '../models/weekly_weather_model.dart';

class WeeklyWeather extends StatelessWidget {
  final WeeklyWeatherModel weeklyWeatherModel;

  const WeeklyWeather({Key? key, required this.weeklyWeatherModel})
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
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              Column(
                children: [
                  WeatherTemperature(
                    temp: weeklyWeatherModel.temp!,
                    tempFeelsLike: weeklyWeatherModel.tempFeelsLike!,
                    tempMin: weeklyWeatherModel.tempMin!,
                    tempMax: weeklyWeatherModel.tempMax!,
                  ),
                  WeatherInfoCard(
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
