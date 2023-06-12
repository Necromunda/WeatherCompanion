import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/combined_weather_model.dart';
import 'package:weather_icons/weather_icons.dart';

import '../models/daily_weather_model.dart';

class SunTimes extends StatelessWidget {
  final DailyWeatherModel weatherModel;
  // final CombinedWeatherModel combinedWeatherModel;

  const SunTimes({Key? key, required this.weatherModel})
  // const SunTimes({Key? key, required this.combinedWeatherModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String sunrise = DateFormat("HH:mm")
        .format(weatherModel.sunrise!);
        // .format(combinedWeatherModel.dailyWeatherModel!.sunrise!);
    String sunset = DateFormat("HH:mm")
        .format(weatherModel.sunset!);
        // .format(combinedWeatherModel.dailyWeatherModel!.sunset!);
    DateTime dt = DateTime.now();

    DateTime tillSunrise = DateTime(
        dt.year,
        dt.month,
        dt.day,
        weatherModel.sunrise!.hour,
        // combinedWeatherModel.dailyWeatherModel!.sunrise!.hour,
        weatherModel.sunrise!.minute);
        // combinedWeatherModel.dailyWeatherModel!.sunrise!.minute);
    DateTime tillSunset = DateTime(
        dt.year,
        dt.month,
        dt.day,
        weatherModel.sunset!.hour,
        // combinedWeatherModel.dailyWeatherModel!.sunset!.hour,
        weatherModel.sunset!.minute);
        // combinedWeatherModel.dailyWeatherModel!.sunset!.minute);

    if (tillSunrise.isBefore(dt)) {
      tillSunrise = tillSunrise.add(const Duration(days: 1));
    }
    if (tillSunset.isBefore(dt)) {
      tillSunset = tillSunset.add(const Duration(days: 1));
    }

    Duration sunriseDifference = tillSunrise.difference(dt);
    Duration sunsetDifference = tillSunset.difference(dt);

    String sunriseDifferenceString =
        '${sunriseDifference.inHours.abs()}h ${sunriseDifference.inMinutes.remainder(60).abs()}m';
    String sunsetDifferenceString =
        '${sunsetDifference.inHours.abs()}h ${sunsetDifference.inMinutes.remainder(60).abs()}m';

    String message = sunriseDifference.compareTo(sunsetDifference).isNegative
        ? 'Sunrise in $sunriseDifferenceString'
        : 'Sunset in $sunsetDifferenceString';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          children: [
            const BoxedIcon(
              WeatherIcons.sunrise,
              color: Color(0xFFF7D466),
            ),
            Text(
              sunrise,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        Text(
          message,
          style: const TextStyle(fontSize: 20),
        ),
        Column(
          children: [
            const BoxedIcon(
              WeatherIcons.sunset,
              color: Colors.deepPurple,
            ),
            Text(
              sunset,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}
