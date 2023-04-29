import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/util.dart';
import 'package:weather_app/widgets/cities.dart';
import 'package:weather_app/widgets/weekly_weather.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class DailyWeather extends StatefulWidget {
  final bool locationPermission;

  // final WeatherModel? data;

  const DailyWeather({
    Key? key,
    required this.locationPermission,
    // required this.data,
  }) : super(key: key);

  @override
  State<DailyWeather> createState() => _DailyWeatherState();
}

class _DailyWeatherState extends State<DailyWeather> {
  // WeatherModel? _weatherModel;
  bool _flipCard = false;
  List<WeatherModel> _favoriteCities = [];
  final TextEditingController _textFieldController = TextEditingController();
  late final bool _locationPermission = widget.locationPermission;
  late WeatherModel? _weatherModel = null;
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("dailyweather initstate");
  }

  void _initPlatformState() async {
    final data = await _getCurrentPositionWeather();
    if (data != null) Util.saveToPrefs("data", data);
    setState(() => _weatherModel = data);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            style: const TextStyle(color: Color(0xFFC256F1)),
            keyboardType: TextInputType.text,
            cursorColor: const Color(0xFFE0C3FC),
            controller: _textFieldController,
            decoration: InputDecoration(
              hintText: "Search by city",
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _getData(_textFieldController.text);
                    Navigator.pop(context);
                  });
                  _textFieldController.clear();
                },
                icon: const Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC256F1)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC256F1)),
              ),
            ),
          ),
          actions: <Widget>[
            ..._favoriteCities.map((city) {
              return Center(
                child: TextButton(
                  child: Text(city.currentCity),
                  onPressed: () {
                    _getData(city.currentCity);
                    Navigator.pop(context);
                  },
                ),
              );
            })
          ],
        );
      },
    );
  }

  void _addToFavorites(WeatherModel? model) {
    if (model != null) {
      if (!_favoriteCities.contains(model)) {
        setState(() {
          _weatherModel!.isFavorite = !_weatherModel!.isFavorite;
          _favoriteCities.add(_weatherModel!);
        });
      } else {
        setState(() {
          _weatherModel!.isFavorite = !_weatherModel!.isFavorite;
          _favoriteCities.remove(model);
        });
      }
    }
  }

  void _gestureDetectorHandler() => setState(() => _flipCard = !_flipCard);

  void _cityGestureHandler() => _displayTextInputDialog(context);

  void _getData(String city) {
    WeatherService.getWeatherByCity(city).then((data) async {
      setState(() {
        _weatherModel = data;
      });
    });
  }

  Future<WeatherModel?> _getCurrentPositionWeather() async {
    if (!_locationPermission) return null;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    WeatherModel? model = await WeatherService.getWeatherByCoords(pos);
    return model;
  }

  // void _getDataPos(Position position) {
  //   WeatherService.getWeatherByCoords(position).then((data) {
  //     setState(() {
  //       _weatherModel = data;
  //     });
  //   });
  // }

  Widget get _loadingWeatherData {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 75,
            height: 75,
            child: LoadingIndicator(
              indicatorType: Indicator.ballRotateChase,
              colors: [Colors.white],
              strokeWidth: 2,
            ),
          ),
          Text("Loading weather data"),
        ],
      ),
    );
  }

  String _convertDegreesToText(double deg) {
    int degrees = (deg * 8 / 360).round();
    degrees = (degrees + 8) % 8;
    return _directions[degrees];
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding daily weather");
    return !_locationPermission && _weatherModel == null
        ? Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Image.asset("assets/images/cloud_colored4.png"),
                ),
              ),
              GestureDetector(
                onTap: _cityGestureHandler,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 3.0),
                      bottom: BorderSide(color: Colors.black, width: 3.0),
                    ),
                  ),
                  child: const Text(
                    "Tap to search",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )
        : _weatherModel == null
            ? _loadingWeatherData
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          color: Colors.black, width: 3.0),
                                      bottom: BorderSide(
                                          color: Colors.black, width: 3.0),
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: _cityGestureHandler,
                                    child: Text(
                                      _weatherModel!.currentCity,
                                      style: const TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // IconButton(
                                //   onPressed: () => _addToFavorites(_weatherModel),
                                //   icon: Icon(
                                //     _weatherModel!.isFavorite
                                //         ? Icons.star
                                //         : Icons.star_outline,
                                //     size: 35,
                                //   ),
                                //   color:
                                //       _weatherModel!.isFavorite ? Colors.yellow : Colors.grey,
                                // ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text(
                                DateFormat.MMMMEEEEd().format(DateTime.now()),
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                // ..._titles.map((e) => e),
                                Text(
                                  "Min",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
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
                                // ..._temps.map((e) => e),
                                Text(
                                  "${(_weatherModel?.tempMin)?.round()}°C",
                                  style: const TextStyle(fontSize: 25),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Text(
                                    "${(_weatherModel?.temp)?.round()}°C",
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                                Text(
                                  "${(_weatherModel?.tempMax)?.round()}°C",
                                  style: const TextStyle(fontSize: 25),
                                ),
                              ],
                            ),
                            Text(
                              "Feels like ${(_weatherModel?.tempFeelsLike)?.round()}°C",
                              style: TextStyle(fontSize: 20),
                            ),
                            GestureDetector(
                              onTap: _gestureDetectorHandler,
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black)),
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: !_flipCard
                                    ? Column(
                                        children: [
                                          Image.network(
                                              _weatherModel!.iconUrl!),
                                          Text(
                                            "${toBeginningOfSentenceCase(_weatherModel?.weatherTypeDescription)}",
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: const [
                                                // ..._statTitles.map((e) => e),
                                                Text(
                                                  "Visibility",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  "Air pressure",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  "Humidity",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                Text(
                                                  "Wind direction",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // ..._statValues.map((e) => e),
                                                Text(
                                                  "${(_weatherModel!.visibility! / 1000).round()} km",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  "${(_weatherModel?.pressure)} hpa",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  "${(_weatherModel?.humidity)} %",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  _convertDegreesToText(
                                                      _weatherModel!.windDeg!),
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.red)),
                      child: WeeklyWeather(
                        hasLocationPermission: _locationPermission,
                      ),
                    ),
                  ),
                ],
              );
  }
}
