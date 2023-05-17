import 'package:flutter/material.dart';

class WeatherTemperature extends StatelessWidget {
  final double temp, tempFeelsLike, tempMin, tempMax;

  const WeatherTemperature(
      {Key? key,
      required this.temp,
      required this.tempFeelsLike,
      required this.tempMin,
      required this.tempMax})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Min",
              style: TextStyle(fontSize: 15),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Current",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Text(
              "Max",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${(tempMin.round())}°C",
              style: const TextStyle(fontSize: 25),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "${temp.round()}°C",
                style: const TextStyle(fontSize: 40),
              ),
            ),
            Text(
              "${tempMax.round()}°C",
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
        Text(
          "Feels like ${tempFeelsLike.round()}°C",
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
