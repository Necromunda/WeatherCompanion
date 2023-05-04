import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_model.dart';

class WeatherInfoCard extends StatefulWidget {
  final String iconUrl, weatherTypeDescription;
  final double visibility, humidity, pressure, windDeg;

  const WeatherInfoCard({
    Key? key,
    required this.iconUrl,
    required this.weatherTypeDescription,
    required this.visibility,
    required this.humidity,
    required this.pressure,
    required this.windDeg,
  }) : super(key: key);

  @override
  State<WeatherInfoCard> createState() => _WeatherInfoCardState();
}

class _WeatherInfoCardState extends State<WeatherInfoCard> {
  late final String _iconUrl = widget.iconUrl,
      _weatherTypeDescription = widget.weatherTypeDescription;
  late final double _visibility = widget.visibility,
      _humidity = widget.humidity,
      _pressure = widget.pressure,
      _windDeg = widget.windDeg;
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
                  Image.network(_iconUrl),
                  Text(
                    "${toBeginningOfSentenceCase(_weatherTypeDescription)}",
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
                          "${(_visibility / 1000).round()} km",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "$_pressure hpa",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "${_humidity.round()} %",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          _convertDegreesToText(_windDeg),
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
