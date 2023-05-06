import 'package:flutter/material.dart';
import 'package:weather_app/models/favorite_city_model.dart';

class SearchLocationWeather extends StatefulWidget {
  final Function cityGestureHandler;
  final List<FavoriteCityModel> favoriteCities;

  const SearchLocationWeather(
      {Key? key,
      required this.cityGestureHandler,
      required this.favoriteCities})
      : super(key: key);

  @override
  State<SearchLocationWeather> createState() => _SearchLocationWeatherState();
}

class _SearchLocationWeatherState extends State<SearchLocationWeather> {
  late final Function _cityGestureHandler = widget.cityGestureHandler;
  late final List<FavoriteCityModel> _favoriteCities = widget.favoriteCities;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Image.asset("assets/images/cloud_colored4.png"),
          ),
        ),
        GestureDetector(
          onTap: () => _cityGestureHandler(),
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
    );
  }
}
