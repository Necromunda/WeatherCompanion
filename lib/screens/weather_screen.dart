/* TODO
Add possibility to see full weather from history
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../util.dart';

import '../services/weather_service.dart';

import '../models/favorite_city_model.dart';
import '../models/weather_model.dart';
import '../models/weekly_weather_model.dart';

import '../widgets/search_location.dart';
import '../widgets/sun_times.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/weather_temps.dart';
import '../widgets/weekly_weather_showcase.dart';

class Weather extends StatefulWidget {
  final bool locationPermission;
  final Function addPreviousSearch;

  const Weather({
    Key? key,
    required this.locationPermission,
    required this.addPreviousSearch,
  }) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather>
    with AutomaticKeepAliveClientMixin<Weather> {
  List<FavoriteCityModel> _favoriteCities = [];
  final TextEditingController _textFieldController = TextEditingController();
  late final bool _locationPermission = widget.locationPermission;
  DailyWeatherModel? _weatherModel;
  List<WeeklyWeatherModel>? _weeklyWeather;
  DateTime? _lastRequest;
  final int _timeBetweenRequests = 30;

  @override
  bool get wantKeepAlive => true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didUpdateWidget(covariant Weather oldWidget) {
    _getFavoriteCities();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("dailyweather initstate");
  }

  void _initPlatformState() async {
    _getHometown().then((home) {
      if (home == null) {
        _getCurrentPositionWeather();
      } else {
        _getHometownWeather(home);
      }
    });
    _getFavoriteCities();
  }

  bool _allowRequest() {
    DateTime now = DateTime.now();

    if (_lastRequest == null) {
      setState(() {
        _lastRequest = DateTime.now();
      });
      return true;
    }

    Duration difference = now.difference(_lastRequest!);

    if (difference >= Duration(seconds: _timeBetweenRequests)) {
      setState(() {
        _lastRequest = now;
      });
      return true;
    } else {
      return false;
    }
  }

  int get _allowRequestIn =>
      _timeBetweenRequests -
      DateTime.now().difference(_lastRequest ?? DateTime.now()).inSeconds;

  Future<String?> _getHometown() async {
    try {
      final value = await Util.loadFromPrefs("home");
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  void _getFavoriteCities() {
    try {
      Util.loadFromPrefs("favoriteCities").then((value) {
        if (value != null) {
          List<dynamic> jsonList = jsonDecode(value) as List<dynamic>;
          setState(() => _favoriteCities = jsonList
              .map((e) => FavoriteCityModel.createFavoriteCity(e))
              .toList());
        } else {
          setState(() {
            _favoriteCities.clear();
          });
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
        if (contains == 0) {
          final favCity = FavoriteCityModel.createFavoriteCity(
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
    bool res = _allowRequest();
    if (res) {
      final dailyWeatherData = await WeatherService.getWeatherByCity(city);
      if (dailyWeatherData == null) {
        Util.showSnackBar(context, "No data found for $city");
        return;
      }

      // Map<String, double>? coords = await WeatherService.getCoordsByCity(city);
      // if (coords == null) return;

      final List<dynamic>? weeklyWeatherData =
          await WeatherService.getWeeklyWeatherByCoords(
              // coords["lat"]!, coords["lon"]!);
              dailyWeatherData.lat!,
              dailyWeatherData.lon!);
      if (weeklyWeatherData == null) {
        Util.showSnackBar(context, "No weekly data found for $city");
        return;
      }

      setState(() {
        _weatherModel = dailyWeatherData;
        _weeklyWeather = _parseWeekData(weeklyWeatherData);
      });
      // widget.addPreviousSearch({
      //   "name": _weatherModel!.currentCity,
      //   "temp": _weatherModel!.temp,
      //   "date": DateTime.now(),
      // });
      widget.addPreviousSearch(
          {"daily": _weatherModel, "weekly": _weeklyWeather});
    } else {
      Util.showSnackBar(
          context, "Please wait $_allowRequestIn seconds between requests");
    }
  }

/*  void _getHometownWeather(String home) {
    // print("hometown");
    WeatherService.getCoordsByCity(home).then((value) async {
      if (value != null) {
        Position pos = Position(
            longitude: value["lon"]!,
            latitude: value["lat"]!,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0);
        DailyWeatherModel? model = await WeatherService.getWeatherByCoords(pos);
        if (model == null) return;

        final List<dynamic>? weeklyWeatherData =
            await WeatherService.getWeeklyWeatherByCoords(
                pos.latitude, pos.longitude);
        if (weeklyWeatherData == null) return;

        setState(() {
          _weatherModel = model;
          _weeklyWeather = _parseWeekData(weeklyWeatherData);
        });
        // widget.addPreviousSearch({
        //   "name": _weatherModel!.currentCity,
        //   "temp": _weatherModel!.temp,
        //   "date": DateTime.now(),
        // });
        widget.addPreviousSearch(_weatherModel);
      }
    });
  }*/

  void _getHometownWeather(String home) async {
    DailyWeatherModel? dailyWeatherModel =
        await WeatherService.getWeatherByCity(home);
    if (dailyWeatherModel == null) return;

    final List<dynamic>? weeklyWeatherData =
        await WeatherService.getWeeklyWeatherByCoords(
            dailyWeatherModel.lat!, dailyWeatherModel.lon!);
    if (weeklyWeatherData == null) return;

    setState(() {
      _weatherModel = dailyWeatherModel;
      _weeklyWeather = _parseWeekData(weeklyWeatherData);
    });
    // widget.addPreviousSearch({
    //   "name": _weatherModel!.currentCity,
    //   "temp": _weatherModel!.temp,
    //   "date": DateTime.now(),
    // });
    widget
        .addPreviousSearch({"daily": _weatherModel, "weekly": _weeklyWeather});
  }

  void _getCurrentPositionWeather() async {
    if (!_locationPermission) return null;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    DailyWeatherModel? model = await WeatherService.getWeatherByCoords(pos);
    if (model == null) return;

    final List<dynamic>? weeklyWeatherData =
        await WeatherService.getWeeklyWeatherByCoords(
            pos.latitude, pos.longitude);
    if (weeklyWeatherData == null) return;

    setState(() {
      _weatherModel = model;
      _weeklyWeather = _parseWeekData(weeklyWeatherData);
    });
    // widget.addPreviousSearch({
    //   "name": _weatherModel!.currentCity,
    //   "temp": _weatherModel!.temp,
    //   "date": DateTime.now(),
    // });
    widget
        .addPreviousSearch({"daily": _weatherModel, "weekly": _weeklyWeather});
  }

  List<WeeklyWeatherModel>? _parseWeekData(List<dynamic> data) {
    int daysAdded = 0;
    try {
      List<WeeklyWeatherModel> parsedDates = [];

      for (final obj in data) {
        DateTime dt = DateTime.parse(obj["dt_txt"]);
        if (dt.hour == 12 && dt.day != DateTime.now().day) {
          daysAdded++;
          WeeklyWeatherModel.createWeeklyWeatherModel(obj)
              .then((value) => parsedDates.add(value!));
        }
      }
      if (daysAdded < 5) {
        WeeklyWeatherModel.createWeeklyWeatherModel(data.last)
            .then((value) => parsedDates.add(value!));
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
                            WeatherTemperature(
                              temp: _weatherModel!.temp!,
                              tempFeelsLike: _weatherModel!.tempFeelsLike!,
                              tempMin: _weatherModel!.tempMin!,
                              tempMax: _weatherModel!.tempMax!,
                            ),
                            WeatherInfoCard(
                              iconUrl: _weatherModel!.iconUrl!,
                              weatherTypeDescription:
                                  _weatherModel!.weatherTypeDescription!,
                              visibility: _weatherModel!.visibility!,
                              humidity: _weatherModel!.humidity!,
                              pressure: _weatherModel!.pressure!,
                              windDeg: _weatherModel!.windDeg!,
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
