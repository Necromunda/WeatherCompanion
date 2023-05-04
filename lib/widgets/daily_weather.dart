import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:weather_app/models/favorite_city_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/util.dart';
import 'package:weather_app/widgets/search_location.dart';
import 'package:weather_app/widgets/sun_times.dart';
import 'package:weather_app/widgets/weather_info_card.dart';
import 'package:weather_app/widgets/weather_temps.dart';
import 'package:weather_app/widgets/weekly_weather_showcase.dart';

class DailyWeather extends StatefulWidget {
  final bool locationPermission;
  final Function addPreviousSearch;

  // final WeatherModel? data;

  const DailyWeather({
    Key? key,
    required this.locationPermission,
    required this.addPreviousSearch,
  }) : super(key: key);

  @override
  State<DailyWeather> createState() => _DailyWeatherState();
}

class _DailyWeatherState extends State<DailyWeather>
    with AutomaticKeepAliveClientMixin<DailyWeather> {
  // List<String> _favoriteCities = [];
  List<FavoriteCity> _favoriteCities = [
    // FavoriteCity(name: "Oulu, FI", home: true),
  ];
  final TextEditingController _textFieldController = TextEditingController();
  late final bool _locationPermission = widget.locationPermission;
  late WeatherModel? _weatherModel = null;
  List<Map<String, dynamic>>? _weeklyWeather = null;

  @override
  bool get wantKeepAlive => true;

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

  void _initPlatformState() {
    _getCurrentPositionWeather();
    _getFavoriteCities();
  }

  void _getFavoriteCities() {
    try {
      Util.loadFromPrefs("favoriteCities").then((value) {
        if (value != null) {
          List<dynamic> jsonList = jsonDecode(value) as List<dynamic>;
          // jsonList.map((e) => print(e.runtimeType));
          // print(value);
          setState(() => _favoriteCities =
              jsonList.map((e) => FavoriteCity.createFavoriteCity(e)).toList());
        }
      });
    } catch (e, stackTrace) {
      debugPrint("$e, $stackTrace");
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            autofocus: true,
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
                icon: Icon(
                  Icons.search,
                  size: 30,
                  color: Theme.of(context).primaryColor,
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
                  child: Text(city.name),
                  onPressed: () {
                    _getData(city.name);
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

  void _addToFavorites(String? model) {
    setState(() {
      if (model != null) {
        final contains =
            _favoriteCities.where((element) => element.name == model).length;
        // if (!_favoriteCities.contains(model)) {
        if (contains == 0) {
          // _favoriteCities.add(_weatherModel!.currentCity);
          final favCity = FavoriteCity.createFavoriteCity(
              {"name": _weatherModel!.currentCity, "home": false});
          _favoriteCities.add(favCity);
        } else {
          _favoriteCities.remove(_favoriteCities[
              _favoriteCities.indexWhere((element) => element.name == model)]);
        }
        Util.saveToPrefs("favoriteCities", _favoriteCities);
      }
    });
  }

  void _cityGestureHandler() => _displayTextInputDialog(context);

  void _getData(String city) async {
    final dailyWeatherData = await WeatherService.getWeatherByCity(city);
    if (dailyWeatherData == null) {
      Util.showSnackBar(context, "No data found for $city");
      return;
    }

    Map<String, double>? coords = await WeatherService.getCoordsByCity(city);
    if (coords == null) return;

    final List<dynamic>? weeklyWeatherData =
        await WeatherService.getWeeklyWeatherByCoords(
            coords["lat"]!, coords["lon"]!);
    if (weeklyWeatherData == null) {
      Util.showSnackBar(context, "No weekly data found for $city");
      return;
    }

    setState(() {
      _weatherModel = dailyWeatherData;
      _weeklyWeather = _parseWeekData(weeklyWeatherData);
    });
    widget.addPreviousSearch({
      "name": _weatherModel!.currentCity,
      "temp": _weatherModel!.temp,
      "date": DateTime.now(),
    });
  }

  void _getCurrentPositionWeather() async {
    if (!_locationPermission) return null;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    WeatherModel? model = await WeatherService.getWeatherByCoords(pos);
    if (model == null) return;

    final List<dynamic>? weeklyWeatherData =
        await WeatherService.getWeeklyWeatherByCoords(
            pos.latitude, pos.longitude);
    if (weeklyWeatherData == null) return;

    setState(() {
      _weatherModel = model;
      _weeklyWeather = _parseWeekData(weeklyWeatherData);
    });
    widget.addPreviousSearch({
      "name": _weatherModel!.currentCity,
      "temp": _weatherModel!.temp,
      "date": DateTime.now(),
    });
  }

  List<Map<String, dynamic>>? _parseWeekData(List<dynamic> data) {
    try {
      List<Map<String, dynamic>> parsedDates = [];

      for (final obj in data) {
        DateTime dt = DateTime.parse(obj["dt_txt"]);
        if (dt.hour == 12 && dt.day != DateTime.now().day) {
          String day = DateFormat.E().format(dt);
          parsedDates.add({
            "dayAbbr": day,
            "temp": obj["main"]["temp"],
            "icon": obj["weather"][0]["icon"],
          });
        }
      }
      if (parsedDates.length < 5) {
        DateTime dt = DateTime.parse(data.last["dt_txt"]);
        String day = DateFormat.E().format(dt);
        parsedDates.add({
          "dayAbbr": day,
          "temp": data.last["main"]["temp"],
          "icon": data.last["weather"][0]["icon"],
        });
      }
      return parsedDates;
    } catch (e, stacktrace) {
      print("$e, $stacktrace");
      return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("rebuilding daily weather");

    return !_locationPermission && _weatherModel == null
        ? SearchLocationWeather(
            cityGestureHandler: _cityGestureHandler,
            favoriteCities: _favoriteCities)
        // Column(
        //         children: [
        //           Padding(
        //             padding: EdgeInsets.symmetric(vertical: 30.0),
        //             child: Container(
        //               width: MediaQuery.of(context).size.width * 0.9,
        //               child: Image.asset("assets/images/cloud_colored4.png"),
        //             ),
        //           ),
        //           GestureDetector(
        //             onTap: _cityGestureHandler,
        //             child: Container(
        //               decoration: const BoxDecoration(
        //                 border: Border(
        //                   top: BorderSide(color: Colors.black, width: 3.0),
        //                   bottom: BorderSide(color: Colors.black, width: 3.0),
        //                 ),
        //               ),
        //               child: const Text(
        //                 "Tap to search",
        //                 style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        //               ),
        //             ),
        //           ),
        //         ],
        //       )
        : _weatherModel == null
            ? _loadingWeatherData
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    _favoriteCities
                                            .where((element) =>
                                                element.name ==
                                                    _weatherModel!
                                                        .currentCity &&
                                                element.home)
                                            .isEmpty
                                        ? null
                                        : Icons.home,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
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
                                      style: TextStyle(
                                          fontSize: _weatherModel!.currentCity
                                                      .characters.length <=
                                                  15
                                              ? 35
                                              : 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _addToFavorites(
                                      _weatherModel!.currentCity),
                                  icon: Icon(
                                    _favoriteCities
                                            .where((element) =>
                                                element.name ==
                                                _weatherModel!.currentCity)
                                            .isEmpty
                                        ? Icons.star_outline
                                        : Icons.star,
                                    size: 30,
                                  ),
                                  color: _favoriteCities
                                          .where((element) =>
                                              element.name ==
                                              _weatherModel!.currentCity)
                                          .isEmpty
                                      ? Colors.grey
                                      : Colors.yellow,
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                DateFormat.MMMMEEEEd().format(DateTime.now()),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            WeatherTemperature(weatherModel: _weatherModel!),
                            WeatherInfoCard(
                              weatherModel: _weatherModel!,
                            ),
                            SunTimes(weatherModel: _weatherModel!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _weeklyWeather == null
                        ? Center(
                            child: _loadingWeatherData,
                          )
                        : WeeklyWeatherShowcase(
                            weeklyWeather: _weeklyWeather!,
                          ),
                  ),
                ],
              );
  }
}
