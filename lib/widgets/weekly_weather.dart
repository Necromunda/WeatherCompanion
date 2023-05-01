import 'package:flutter/material.dart';

class WeeklyWeather extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyWeather;

  const WeeklyWeather({Key? key, required this.weeklyWeather})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...weeklyWeather.map(
            (obj) {
              return Column(
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
                    "${(obj["temp"] as double).round()}°C",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
