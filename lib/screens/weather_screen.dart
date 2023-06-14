import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:weather_app/widgets/tri_hour_grid.dart';

import '../models/combined_weather_model.dart';
import '../models/favorite_city_model.dart';
import '../models/daily_weather_model.dart';
import '../models/weekly_weather_model.dart';

import '../widgets/search_location.dart';
import '../widgets/sun_times.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/weather_temps.dart';
import '../widgets/weekly_weather_showcase.dart';

import '/screens/tri_hour_weather_screen.dart';

import '../services/weather_service.dart';

import '../util.dart';

enum WeatherData { home, city, location }

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

class _WeatherState extends State<Weather> with AutomaticKeepAliveClientMixin<Weather> {
  final TextEditingController _textFieldController = TextEditingController();
  final ScrollController _gridController = ScrollController();
  final PageController _pageController = PageController(initialPage: 0);

  CombinedWeatherModel? _combinedWeatherModel;

  // DailyWeatherModel? _dailyWeatherModel;
  // List<WeeklyWeatherModel>? _weeklyWeatherModel;
  // List<WeeklyWeatherModel>? _parsedWeeklyWeatherModel;
  List<FavoriteCityModel> _favoriteCities = [];

  late final bool _locationPermission = widget.locationPermission;
  late bool _isCurrentWeatherSelected;

  final int _timeBetweenRequests = 5;

  DateTime? _lastRequest;

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
    // print("dailyweather initstate");
  }

  void _initPlatformState() async {
    _isCurrentWeatherSelected = true;
    _getHometown().then((hometown) {
      if (hometown == null) {
        // _getCurrentPositionWeather();
        _getWeatherData(WeatherData.location);
      } else {
        // _getHometownWeather(home);
        _getWeatherData(WeatherData.home, hometown);
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
      _timeBetweenRequests - DateTime.now().difference(_lastRequest ?? DateTime.now()).inSeconds;

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
              // .map((e) => FavoriteCityModel.createFavoriteCity(e))
              .map((e) => FavoriteCityModel.fromJson(e))
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
                    // _getData(_textFieldController.text);
                    _getWeatherData(WeatherData.city, _textFieldController.text);
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
            ..._favoriteCities.map(
              (city) {
                return Center(
                  child: city.name != null
                      ? TextButton(
                          child: Text(city.name!),
                          onPressed: () {
                            // _getData(city.name!);
                            _getWeatherData(WeatherData.city, city.name);
                            Navigator.pop(context);
                          },
                        )
                      : null,
                );
              },
            )
          ],
        );
      },
    );
  }

  void _addToFavorites(String? model) {
    if (model != null) {
      if (_favoriteCities.length + 1 > 5) {
        Util.showSnackBar(context, "You have 5/5 cities favorited");
        return;
      }
      final bool contains = _isInFavorites(model);
      if (!contains) {
        // final favCity = FavoriteCityModel.createFavoriteCity(
        final favCity = FavoriteCityModel.fromJson(
            // {"name": _dailyWeatherModel?.currentCity, "home": false});
            {"name": _combinedWeatherModel?.dailyWeatherModel?.currentCity, "home": false});
        setState(() => _favoriteCities.add(favCity));
      }
      Util.saveToPrefs("favoriteCities", _favoriteCities);
    }
  }

  void _removeFromFavorites(String? model) {
    if (model != null) {
      setState(() {
        _favoriteCities.remove(
            _favoriteCities[_favoriteCities.indexWhere((element) => element.name == model)]);
      });
      Util.saveToPrefs("favoriteCities", _favoriteCities);
    }
  }

  bool _isInFavorites(String? model) {
    if (model != null) {
      final contains = _favoriteCities.where((element) => element.name == model).isNotEmpty;
      // print(contains);
      return contains;
    } else {
      return true;
    }
  }

  void _cityGestureHandler() => _displayTextInputDialog(context);

  void _getWeatherData(WeatherData type, [String? param]) async {
    DailyWeatherModel? dailyWeatherModel;
    List<WeeklyWeatherModel>? weeklyWeatherModel;
    bool isRequestAllowed = _allowRequest();

    switch (type) {
      case WeatherData.home:
      case WeatherData.city:
        if (type == WeatherData.home ? true : isRequestAllowed) {
          dailyWeatherModel = await WeatherService.getWeatherByCity(param ?? "");
          weeklyWeatherModel = await WeatherService.getWeeklyWeatherByCoords(
              dailyWeatherModel?.lat, dailyWeatherModel?.lon);
        } else {
          Util.showSnackBar(context, "Please wait $_allowRequestIn seconds between requests");
        }
        break;
      case WeatherData.location:
        if (!_locationPermission) break;
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        dailyWeatherModel = await WeatherService.getWeatherByCoords(pos.latitude, pos.longitude);
        weeklyWeatherModel = await WeatherService.getWeeklyWeatherByCoords(
            dailyWeatherModel?.lat, dailyWeatherModel?.lon);
        break;
    }

    if (dailyWeatherModel == null) {
      () => Util.showSnackBar(context, "No data found for $param");
    } else {
      setState(() {
        // _dailyWeatherModel = dailyWeatherModel;
        // _weeklyWeatherModel = weeklyWeatherModel;
        // _parsedWeeklyWeatherModel = _parseWeekData(weeklyWeatherModel);
        _combinedWeatherModel = CombinedWeatherModel(
          // todays weather object
          dailyWeatherModel: dailyWeatherModel,
          // 40 weather objects for the next 6 days
          weeklyWeatherModel: weeklyWeatherModel,
          // 5 weather objects, 1 for each day excluding today
          parsedWeeklyWeatherModel: _parseWeekData(weeklyWeatherModel),
          // Weekly data parsed into lists, each day separately
          parsedTriHourWeatherModel: _parseTriHourWeather(weeklyWeatherModel ?? []),
        );
      });
      widget.addPreviousSearch(
          // {"daily": _dailyWeatherModel, "weekly": _parsedWeeklyWeatherModel},
          _combinedWeatherModel);
      _switchPage(1);
    }
  }

  // void _getData(String city) async {
  //   bool res = _allowRequest();
  //   if (res) {
  //     final dailyWeatherData = await WeatherService.getWeatherByCity(city);
  //     if (dailyWeatherData == null) {
  //       Util.showSnackBar(context, "No data found for $city");
  //       return;
  //     }
  //
  //     final List<dynamic>? weeklyWeatherData =
  //         await WeatherService.getWeeklyWeatherByCoords(
  //             // coords["lat"]!, coords["lon"]!);
  //             dailyWeatherData.lat!,
  //             dailyWeatherData.lon!);
  //     if (weeklyWeatherData == null) {
  //       Util.showSnackBar(context, "No weekly data found for $city");
  //       return;
  //     }
  //
  //     setState(() {
  //       _dailyWeatherModel = dailyWeatherData;
  //       // _weeklyWeatherModel = _parseWeekData(weeklyWeatherData);
  //       _weeklyWeatherModel = weeklyWeatherData
  //           .map((e) => WeeklyWeatherModel.fromJson(e))
  //           .toList();
  //       _parsedWeeklyWeatherModel = _parseWeekData(weeklyWeatherData);
  //     });
  //     widget.addPreviousSearch(
  //       // {"daily": _dailyWeatherModel, "weekly": _weeklyWeatherModel});
  //       {"daily": _dailyWeatherModel, "weekly": _parsedWeeklyWeatherModel},
  //     );
  //     _switchPage(1);
  //   } else {
  //     Util.showSnackBar(
  //         context, "Please wait $_allowRequestIn seconds between requests");
  //   }
  // }
  //
  // void _getHometownWeather(String home) async {
  //   DailyWeatherModel? dailyWeatherModel =
  //       await WeatherService.getWeatherByCity(home);
  //   if (dailyWeatherModel == null) return;
  //
  //   final List<dynamic>? weeklyWeatherData =
  //       await WeatherService.getWeeklyWeatherByCoords(
  //           dailyWeatherModel.lat!, dailyWeatherModel.lon!);
  //   if (weeklyWeatherData == null) return;
  //
  //   setState(() {
  //     _dailyWeatherModel = dailyWeatherModel;
  //     // _weeklyWeatherModel = _parseWeekData(weeklyWeatherData);
  //     _weeklyWeatherModel =
  //         weeklyWeatherData.map((e) => WeeklyWeatherModel.fromJson(e)).toList();
  //     print(_weeklyWeatherModel?.length);
  //     _parsedWeeklyWeatherModel = _parseWeekData(weeklyWeatherData);
  //   });
  //   widget.addPreviousSearch(
  //     // {"daily": _dailyWeatherModel, "weekly": _weeklyWeatherModel},
  //     {"daily": _dailyWeatherModel, "weekly": _parsedWeeklyWeatherModel},
  //   );
  // }
  //
  // void _getCurrentPositionWeather() async {
  //   if (!_locationPermission) return null;
  //   Position pos = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   DailyWeatherModel? model = await WeatherService.getWeatherByCoords(pos.latitude, pos.longitude);
  //   if (model == null) return;
  //
  //   final List<dynamic>? weeklyWeatherData =
  //       await WeatherService.getWeeklyWeatherByCoords(
  //           pos.latitude, pos.longitude);
  //   if (weeklyWeatherData == null) return;
  //
  //   setState(() {
  //     _dailyWeatherModel = model;
  //     // _weeklyWeatherModel = _parseWeekData(weeklyWeatherData);
  //     _weeklyWeatherModel =
  //         weeklyWeatherData.map((e) => WeeklyWeatherModel.fromJson(e)).toList();
  //     _parsedWeeklyWeatherModel = _parseWeekData(weeklyWeatherData);
  //   });
  //   widget.addPreviousSearch(
  //     // {"daily": _dailyWeatherModel, "weekly": _weeklyWeatherModel},
  //     {"daily": _dailyWeatherModel, "weekly": _parsedWeeklyWeatherModel},
  //   );
  // }

  List<WeeklyWeatherModel>? _parseWeekData(List<WeeklyWeatherModel>? data) {
    if (data == null) return null;
    int daysAdded = 0;
    try {
      List<WeeklyWeatherModel> parsedDates = [];

      for (final obj in data) {
        if (obj.dt?.hour == 12 && obj.dt?.day != DateTime.now().day) {
          daysAdded++;
          parsedDates.add(obj);
        }
      }
      if (daysAdded < 5) {
        parsedDates.add(data.last);
      }
      return parsedDates;
    } catch (e, stacktrace) {
      debugPrint("$e, $stacktrace");
      return null;
    }
  }

  // List<WeeklyWeatherModel>? _parseWeekData(List<dynamic> data) {
  //   int daysAdded = 0;
  //   try {
  //     List<WeeklyWeatherModel> parsedDates = [];
  //
  //     for (final obj in data) {
  //       DateTime dt = DateTime.parse(obj["dt_txt"]);
  //       if (dt.hour == 12 && dt.day != DateTime.now().day) {
  //         daysAdded++;
  //         WeeklyWeatherModel.createWeeklyWeatherModel(obj)
  //             .then((value) => parsedDates.add(value!));
  //       }
  //     }
  //     if (daysAdded < 5) {
  //       WeeklyWeatherModel.createWeeklyWeatherModel(data.last)
  //           .then((value) => parsedDates.add(value!));
  //     }
  //     return parsedDates;
  //   } catch (e, stacktrace) {
  //     print("$e, $stacktrace");
  //     return null;
  //   }
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

  void _switchPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _doubleButtonHandler() {
    setState(() {
      _isCurrentWeatherSelected = !_isCurrentWeatherSelected;
    });
  }

  Widget get _doubleButton {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        FilledButton(
          onPressed: _doubleButtonHandler,
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
                _isCurrentWeatherSelected ? const Color(0xFFE0C3FC) : Colors.grey),
          ),
          child: const Text("Current"),
        ),
        FilledButton(
          onPressed: _doubleButtonHandler,
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0), bottomRight: Radius.circular(5.0)),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(
                _isCurrentWeatherSelected ? Colors.grey : const Color(0xFFE0C3FC)),
          ),
          child: const Text("Hourly"),
        ),
      ],
    );
  }

  List<List<WeeklyWeatherModel>> _parseTriHourWeather(List<WeeklyWeatherModel> list) {
    List<WeeklyWeatherModel>? uniques = _parseWeekData(list);
    List<List<WeeklyWeatherModel>> parsedObjects = [];
    List<WeeklyWeatherModel> temp = [];

    for (final obj in list) {
      if (obj.dt!.day == DateTime.now().day) {
        temp.add(obj);
      } else {
        parsedObjects.add(List.from(temp));
        break;
      }
    }
    // print(parsedObjects);
    for (int i = 0; i < uniques!.length; i++) {
      temp.clear();
      for (final obj in list) {
        if (obj.dt!.day == uniques[i].dt!.day) {
          temp.add(obj);
        }
      }
      parsedObjects.add(List.from(temp));
    }

    return parsedObjects;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // print("rebuilding daily weather");

    // return !_locationPermission && _dailyWeatherModel == null
    return PageView(
      // scrollDirection: Axis.vertical,
      controller: _pageController,
      children: [
        SearchLocationWeather(
          // getData: _getData,
          searchCallback: _getWeatherData,
          cityGestureHandler: _cityGestureHandler,
          favoriteCities: _favoriteCities,
        ),
        // _dailyWeatherModel == null && !_locationPermission
        _combinedWeatherModel?.dailyWeatherModel == null && !_locationPermission
            ? const Center(
                child: Text("Enable location in settings or set your hometown"),
              )
            // : _dailyWeatherModel == null && _locationPermission
            : _combinedWeatherModel?.dailyWeatherModel == null && _locationPermission
                ? _loadingWeatherData
                : Column(
                    children: [
                      // !_isCurrentWeatherSelected
                      //     ? Expanded(
                      //         flex: 3,
                      //         child: Padding(
                      //           padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
                      //           child: GridView.count(
                      //             controller: _gridController,
                      //             physics: const BouncingScrollPhysics(),
                      //             addAutomaticKeepAlives: false,
                      //             crossAxisCount: 2,
                      //             crossAxisSpacing: 5.0,
                      //             // mainAxisSpacing: 20.0,
                      //             children: List.generate(
                      //               _combinedWeatherModel!.parsedTriHourWeatherModel!.length,
                      //               (index) {
                      //                 List<WeeklyWeatherModel>? list =
                      //                     _combinedWeatherModel?.parsedTriHourWeatherModel![index];
                      //                 if (list == null) const SizedBox();
                      //
                      //                 String date = DateFormat("d.M").format(list!.first.dt!);
                      //                 // String time = DateFormat("HH:mm").format(list.first.dt!);
                      //                 String day = DateFormat("EEEE").format(list.first.dt!);
                      //
                      //                 return GestureDetector(
                      //                   onTap: () => Navigator.push(
                      //                     context,
                      //                     MaterialPageRoute(
                      //                       builder: (context) => TriHourWeather(
                      //                         weeklyWeatherModel: list,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   child: Card(
                      //                     elevation: 11,
                      //                     clipBehavior: Clip.antiAlias,
                      //                     child: Container(
                      //                       // height: 50,
                      //                       // width: 150,
                      //                       decoration: const BoxDecoration(
                      //                         // gradient: RadialGradient(
                      //                         gradient: LinearGradient(
                      //                           colors: [
                      //                             // Colors.yellow,
                      //                             // Colors.orangeAccent,
                      //                             // Colors.yellow.shade300,
                      //                             // Color(0xFFE0C3FC),
                      //                             Color(0xFFE0C3FC),
                      //                             Color(0xFF8EC5FC),
                      //                           ],
                      //                           begin: Alignment.topCenter,
                      //                           end: Alignment.bottomCenter,
                      //                         ),
                      //                       ),
                      //                       child: Column(
                      //                         mainAxisAlignment: MainAxisAlignment.center,
                      //                         crossAxisAlignment: CrossAxisAlignment.center,
                      //                         children: [
                      //                           Text(
                      //                             day,
                      //                             style: const TextStyle(fontSize: 24),
                      //                           ),
                      //                           Text(
                      //                             date,
                      //                             style: const TextStyle(fontSize: 24),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             ),
                      //           ),
                      //         ),
                      //       )
                      //     :
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
                                          const IconButton(
                                            onPressed: null,
                                            icon: Icon(
                                              // _favoriteCities
                                              //         .where((element) => element
                                              //                         .name ==
                                              //                     _dailyWeatherModel!
                                              //                         .currentCity &&
                                              //                 element.home ==
                                              //                     null
                                              //             ? false
                                              //             : element.home!)
                                              //         .isEmpty
                                              //     ? null
                                              //     : Icons.home,
                                              null,
                                              color: Colors.green,
                                              size: 30,
                                            ),
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                top: BorderSide(color: Colors.black, width: 3.0),
                                                bottom: BorderSide(color: Colors.black, width: 3.0),
                                              ),
                                            ),
                                            child: GestureDetector(
                                              onTap: _cityGestureHandler,
                                              child: Text(
                                                // _dailyWeatherModel!.currentCity,
                                                _combinedWeatherModel!
                                                    .dailyWeatherModel!.currentCity,
                                                style: TextStyle(
                                                    fontSize:
                                                        // _dailyWeatherModel!
                                                        _combinedWeatherModel!
                                                                    .dailyWeatherModel!
                                                                    .currentCity
                                                                    .characters
                                                                    .length <=
                                                                15
                                                            ? 35
                                                            : 30,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _isInFavorites(
                                                    // _dailyWeatherModel!
                                                    _combinedWeatherModel
                                                        ?.dailyWeatherModel!.currentCity)
                                                ? _removeFromFavorites(
                                                    // _dailyWeatherModel!
                                                    _combinedWeatherModel
                                                        ?.dailyWeatherModel!.currentCity)
                                                : _addToFavorites(
                                                    // _dailyWeatherModel!
                                                    _combinedWeatherModel
                                                        ?.dailyWeatherModel!.currentCity),
                                            icon: Icon(
                                              _favoriteCities
                                                      .where((element) =>
                                                          element.name ==
                                                          // _dailyWeatherModel!
                                                          _combinedWeatherModel
                                                              ?.dailyWeatherModel!.currentCity)
                                                      .isEmpty
                                                  ? Icons.star_outline
                                                  : Icons.star,
                                              size: 30,
                                            ),
                                            color: _favoriteCities
                                                    .where((element) =>
                                                        element.name ==
                                                        // _dailyWeatherModel!
                                                        _combinedWeatherModel
                                                            ?.dailyWeatherModel!.currentCity)
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
                                        // combinedWeatherModel: _combinedWeatherModel!,
                                        temp: _combinedWeatherModel!.dailyWeatherModel!.temp!,
                                        tempFeelsLike: _combinedWeatherModel!
                                            .dailyWeatherModel!.tempFeelsLike!,
                                        tempMin: _combinedWeatherModel!.dailyWeatherModel!.tempMin!,
                                        tempMax: _combinedWeatherModel!.dailyWeatherModel!.tempMax!,
                                      ),
                                      WeatherInfoCard(
                                        // combinedWeatherModel: _combinedWeatherModel!,
                                        iconUrl: _combinedWeatherModel!.dailyWeatherModel!.iconUrl!,
                                        weatherTypeDescription: _combinedWeatherModel!
                                            .dailyWeatherModel!.weatherTypeDescription!,
                                        visibility:
                                            _combinedWeatherModel!.dailyWeatherModel!.visibility!,
                                        humidity:
                                            _combinedWeatherModel!.dailyWeatherModel!.humidity!,
                                        pressure:
                                            _combinedWeatherModel!.dailyWeatherModel!.pressure!,
                                        windDeg: _combinedWeatherModel!.dailyWeatherModel!.windDeg!,
                                        windSpeed:
                                            _combinedWeatherModel!.dailyWeatherModel!.windSpeed!,
                                      ),
                                      SunTimes(
                                        // combinedWeatherModel: _combinedWeatherModel!,
                                        weatherModel: _combinedWeatherModel!.dailyWeatherModel!,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                      // _doubleButton,
                      Expanded(
                        child: _combinedWeatherModel?.parsedWeeklyWeatherModel == null
                            ? Center(
                                child: _loadingWeatherData,
                              )
                            : WeeklyWeatherShowcase(
                                // weeklyWeather: _weeklyWeatherModel!,
                                // weeklyWeather: _parsedWeeklyWeatherModel!,
                                combinedWeatherModel: _combinedWeatherModel!,
                              ),
                      ),
                    ],
                  ),
        _combinedWeatherModel == null
            ? const Center(
                child: Text("No data"),
              )
            : TriHourGrid(combinedWeatherModel: _combinedWeatherModel!)
      ],
    );
  }
}
