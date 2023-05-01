import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/util.dart';
import 'package:weather_app/widgets/cities.dart';
import 'package:weather_app/widgets/weather_info_card.dart';
import 'package:weather_app/widgets/weather_temps.dart';
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

class _DailyWeatherState extends State<DailyWeather>
    with AutomaticKeepAliveClientMixin<DailyWeather> {
  List<WeatherModel> _favoriteCities = [];
  final TextEditingController _textFieldController = TextEditingController();
  late final bool _locationPermission = widget.locationPermission;
  late WeatherModel? _weatherModel = null;

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

  void _initPlatformState() async {
    final data = await _getCurrentPositionWeather();
    // if (data != null) Util.saveToPrefs("data", data);
    setState(() => _weatherModel = data);
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

  void _cityGestureHandler() => _displayTextInputDialog(context);

  // void _getData(String city) {
  //   WeatherService.getWeatherByCity(city).then((data) async {
  //     if (data == null) {
  //       Util.showSnackBar(context, "No data found for $city");
  //       return;
  //     }
  //     setState(() {
  //       _weatherModel = data;
  //     });
  //   });
  // }

  void _getData(String city) async {
    final dailyWeatherData = await WeatherService.getWeatherByCity(city);
    if (dailyWeatherData == null) {
      () => Util.showSnackBar(context, "No data found for $city");
      return;
    }

    Map<String, double>? coords = await WeatherService.getCoordsByCity(city);
    if (coords == null) return;

    print("WEEKLY WEATHER:");
    await WeatherService.getWeeklyWeatherByCoords(coords["lat"]!, coords["lon"]!);

    setState(() {
      _weatherModel = dailyWeatherData;
    });
  }

  Future<WeatherModel?> _getCurrentPositionWeather() async {
    if (!_locationPermission) return null;
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    WeatherModel? model = await WeatherService.getWeatherByCoords(pos);
    await WeatherService.getWeeklyWeatherByCoords(pos.latitude, pos.longitude);
    return model;
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
