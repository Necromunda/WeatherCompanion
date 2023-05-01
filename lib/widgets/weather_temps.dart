import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherTemperature extends StatelessWidget {
  final WeatherModel weatherModel;

  const WeatherTemperature({Key? key, required this.weatherModel})
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
              "${(weatherModel.tempMin)?.round()}°C",
              style: const TextStyle(fontSize: 25),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "${(weatherModel.temp)?.round()}°C",
                style: const TextStyle(fontSize: 40),
              ),
            ),
            Text(
              "${(weatherModel.tempMax)?.round()}°C",
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
        Text(
          "Feels like ${(weatherModel.tempFeelsLike)?.round()}°C",
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
