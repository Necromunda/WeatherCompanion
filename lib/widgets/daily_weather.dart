import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_model.dart';

class DailyWeather extends StatefulWidget {
  final WeatherModel weatherModel;

  const DailyWeather({Key? key, required this.weatherModel}) : super(key: key);

  @override
  State<DailyWeather> createState() => _DailyWeatherState();
}

class _DailyWeatherState extends State<DailyWeather> {
  bool _flipCard = false;
  final List<Widget> _titles = [
    const Text(
      "Min",
      style: TextStyle(fontSize: 15),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        "Current",
        style: TextStyle(fontSize: 20),
      ),
    ),
    const Text(
      "Max",
      style: TextStyle(fontSize: 15),
    ),
  ];

  late final List<Widget> _temps = [
    Text(
      "${(widget.weatherModel.tempMin)!.round()}°C",
      style: const TextStyle(fontSize: 25),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        "${(widget.weatherModel.temp)!.round()}°C",
        style: const TextStyle(fontSize: 40),
      ),
    ),
    Text(
      "${(widget.weatherModel.tempMax)!.round()}°C",
      style: const TextStyle(fontSize: 25),
    ),
  ];

  final List<Widget> _statTitles = [
    const Text(
      "Visibility",
      style: TextStyle(fontSize: 18),
    ),
    const Text(
      "Air pressure",
      style: TextStyle(fontSize: 18),
    ),
    const Text(
      "Humidity",
      style: TextStyle(fontSize: 18),
    ),
  ];

  late final List<Widget> _statValues = [
    Text(
      "${(widget.weatherModel.visibility! / 1000).round()} km",
      style: const TextStyle(fontSize: 18),
    ),
    Text(
      "${(widget.weatherModel.pressure!)} hpa",
      style: const TextStyle(fontSize: 18),
    ),
    Text(
      "${(widget.weatherModel.humidity!)} %",
      style: const TextStyle(fontSize: 18),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _gestureDetectorHandler() {
    setState(() {
      _flipCard = !_flipCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.weatherModel.pressure);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 3.0),
                bottom: BorderSide(color: Colors.black, width: 3.0),
              ),
            ),
            child: Text(
              "${widget.weatherModel.city}, ${widget.weatherModel.countryCode}",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._titles.map((e) => e),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._temps.map((e) => e),
          ],
        ),
        GestureDetector(
          onTap: _gestureDetectorHandler,
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.transparent)),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            child: !_flipCard
                ? Column(
                    children: [
                      Image.network(widget.weatherModel.iconUrl!),
                      Text(
                        "${toBeginningOfSentenceCase(widget.weatherModel.weatherTypeDescription)}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ..._statTitles.map((e) => e),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ..._statValues.map((e) => e),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
