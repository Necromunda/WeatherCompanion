import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/cities.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class DailyWeather extends StatefulWidget {
  final WeatherModel? weatherModel;

  const DailyWeather({Key? key, required this.weatherModel}) : super(key: key);

  @override
  State<DailyWeather> createState() => _DailyWeatherState();
}

class _DailyWeatherState extends State<DailyWeather> {
  late WeatherModel? _weatherModel = widget.weatherModel;
  bool _flipCard = false;
  bool _changeCity = false;
  List<WeatherModel> _favoriteCities = [];

  // List<String> _cities = [];
  // late String _currentCity =
  //     "${_weatherModel?.city}, ${_weatherModel?.countryCode}";
  // late String _currentWheelChooserCity;

  String get _currentCity {
    return "${_weatherModel?.city}, ${_weatherModel?.countryCode}";
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("initstate");
  }

  void _initPlatformState() {
    if (_weatherModel != null) {
      setState(() => _favoriteCities.add(_weatherModel!));
    }
  }

  void _gestureDetectorHandler() {
    print("flip card");
    setState(() => _flipCard = !_flipCard);
  }

  void _cityGestureHandler() {
    print("change city");
    setState(() => _changeCity = !_changeCity);
  }

  void _getData(String city) {
    WeatherService.getWeatherByCity(city).then((data) async {
      setState(() {
        _weatherModel = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _weatherModel = widget.weatherModel;
      // _cities = [_currentCity];
    });
    print("rebuilding daily weather");
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.star,
                  color: Colors.black,
                )),
            IconButton(
              onPressed: null,
              icon: Icon(Icons.search),
              color: Colors.black,
            ),
            IconButton(
              onPressed: null,
              icon: Icon(Icons.settings),
              color: Colors.black,
            ),
          ],
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
              _currentCity,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
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
                // ..._temps.map((e) => e),
                Text(
                  "${(_weatherModel?.tempMin)?.round()}°C",
                  style: const TextStyle(fontSize: 25),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
          ],
        ),

        GestureDetector(
          onTap: _gestureDetectorHandler,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            child: !_flipCard
                ? Column(
                    children: [
                      Image.network(_weatherModel!.iconUrl!),
                      Text(
                        "${toBeginningOfSentenceCase(_weatherModel?.weatherTypeDescription)}",
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
                            // ..._statTitles.map((e) => e),
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // ..._statValues.map((e) => e),
                            Text(
                              "${(_weatherModel!.visibility! / 1000).round()} km",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              "${(_weatherModel?.pressure)} hpa",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              "${(_weatherModel?.humidity)} %",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
      // ),
      // ],
    );
  }
}
