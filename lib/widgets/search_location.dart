import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather_app/util.dart';

import '../models/favorite_city_model.dart';

class SearchLocationWeather extends StatefulWidget {
  final Function getData;
  final Function cityGestureHandler;
  final List<FavoriteCityModel> favoriteCities;

  const SearchLocationWeather({
    Key? key,
    required this.getData,
    required this.cityGestureHandler,
    required this.favoriteCities,
  }) : super(key: key);

  @override
  State<SearchLocationWeather> createState() => _SearchLocationWeatherState();
}

class _SearchLocationWeatherState extends State<SearchLocationWeather> {
  late final Function _getData = widget.getData;
  late final Function _cityGestureHandler = widget.cityGestureHandler;
  late List<FavoriteCityModel> _favoriteCities = widget.favoriteCities;

  @override
  void initState() {
    _getFavoriteCities();
    super.initState();
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: _favoriteCities.isEmpty
                ? null
                : Card(
                    // elevation: 7,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(
                            "Quickmenu",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        ..._favoriteCities.map(
                          (city) {
                            return Center(
                              child: TextButton(
                                child: Text(
                                  city.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF8EC5FC),
                                  ),
                                ),
                                onPressed: () {
                                  _getData(city.name);
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
