import 'package:flutter/material.dart';

import '../models/combined_weather_model.dart';

import '../screens/weekly_weather_screen.dart';

class WeeklyWeatherShowcase extends StatelessWidget {
  // final List<WeeklyWeatherModel> weeklyWeather;
  final CombinedWeatherModel combinedWeatherModel;

  // const WeeklyWeatherShowcase({Key? key, required this.weeklyWeather})
  const WeeklyWeatherShowcase({Key? key, required this.combinedWeatherModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ...weeklyWeather.map(
          ...combinedWeatherModel.parsedWeeklyWeatherModel!.map(
            (model) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WeeklyWeatherScreen(weeklyWeatherModel: model),
                        // WeeklyWeatherScreen(combinedWeatherModel: combinedWeatherModel),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      model.dayAbbr!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Image.network(
                      model.iconUrl!,
                      scale: 1.5,
                    ),
                    Text(
                      "${model.temp!.round()}°C",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
