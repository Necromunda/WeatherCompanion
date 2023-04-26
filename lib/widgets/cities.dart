import 'package:flutter/material.dart';

import '../models/weather_model.dart';

class Cities extends StatefulWidget {
  final List<WeatherModel> favoriteCities;

  const Cities({Key? key, required this.favoriteCities}) : super(key: key);

  @override
  State<Cities> createState() => _CitiesState();
}

class _CitiesState extends State<Cities> {
  late List<WeatherModel> _favoriteCities = widget.favoriteCities;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        // color: Color(0xFFE0C3FC),
        width: MediaQuery.of(context).size.width,
        child: Card(
            elevation: 5,
            color: Color(0xFFE0C3FC),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(keyboardType: TextInputType.text, ),
                ..._favoriteCities.map((model) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${model.city}, ${model.countryCode}",
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  );
                })
              ],
            )),
      ),
    );
  }
}
