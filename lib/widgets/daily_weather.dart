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
  List<WeatherModel> _favoriteCities = [];
  final TextEditingController _textFieldController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("initstate");
  }

  void _initPlatformState() {}

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

  @override
  Widget build(BuildContext context) {
    print("rebuilding daily weather");
    return _weatherModel == null
        ? Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 3.0),
          bottom: BorderSide(color: Colors.black, width: 3.0),
        ),
      ),
      child: GestureDetector(
        onTap: _cityGestureHandler,
        child: const Text(
          "Tap to search a city",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
    )
        : Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
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
                  _weatherModel!.currentCity,
                  style: const TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _addToFavorites(_weatherModel),
              icon: Icon(
                _weatherModel!.isFavorite
                    ? Icons.star
                    : Icons.star_outline,
                size: 35,
              ),
              color:
              _weatherModel!.isFavorite ? Colors.yellow : Colors.grey,
            ),
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
            decoration:
            BoxDecoration(border: Border.all(color: Colors.black)),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.2,
            child: !_flipCard
                ? Column(
              children: [
                Image.network(_weatherModel!.iconUrl!),
                Text(
                  "${toBeginningOfSentenceCase(
                      _weatherModel?.weatherTypeDescription)}",
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
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
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
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
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
    );
  }
}
