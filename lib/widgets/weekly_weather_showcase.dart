import 'package:flutter/material.dart';
import 'package:weather_app/screens/weekly_weather_screen.dart';

class WeeklyWeatherShowcase extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyWeather;

  const WeeklyWeatherShowcase({Key? key, required this.weeklyWeather})
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
          ...weeklyWeather.map(
            (obj) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyWeatherScreen(),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      obj["dayAbbr"],
                      style: const TextStyle(fontSize: 20),
                    ),
                    Image.network(
                      "https://openweathermap.org/img/wn/${obj["icon"]}@2x.png",
                      scale: 1.5,
                    ),
                    Text(
                      "${(obj["temp"].toDouble()).round()}°C",
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
