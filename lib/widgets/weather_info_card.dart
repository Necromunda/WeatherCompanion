import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherInfoCard extends StatefulWidget {
  final WeatherModel weatherModel;

  const WeatherInfoCard({Key? key, required this.weatherModel})
      : super(key: key);

  @override
  State<WeatherInfoCard> createState() => _WeatherInfoCardState();
}

class _WeatherInfoCardState extends State<WeatherInfoCard> {
  late final WeatherModel _weatherModel = widget.weatherModel;
  late bool _flipCard = false;
  static const List<String> _directions = [
    'north',
    'northeast',
    'east',
    'southeast',
    'south',
    'southwest',
    'west',
    'northwest'
  ];

  String _convertDegreesToText(double deg) {
    int degrees = (deg * 8 / 360).round();
    degrees = (degrees + 8) % 8;
    return _directions[degrees];
  }

  void _gestureDetectorHandler() => setState(() => _flipCard = !_flipCard);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _gestureDetectorHandler,
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.2,
        child: !_flipCard
            ? Column(
                children: [
                  Image.network(_weatherModel.iconUrl!),
                  Text(
                    "${toBeginningOfSentenceCase(_weatherModel.weatherTypeDescription)}",
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
                      children: const [
                        Text(
                          "Visibility",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Air pressure",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Humidity",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Wind direction",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "${(_weatherModel.visibility! / 1000).round()} km",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "${(_weatherModel.pressure)} hpa",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "${(_weatherModel.humidity)} %",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          _convertDegreesToText(_weatherModel.windDeg!),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
