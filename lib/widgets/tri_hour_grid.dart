import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/combined_weather_model.dart';
import '../models/weekly_weather_model.dart';
import '../screens/tri_hour_weather_screen.dart';

class TriHourGrid extends StatefulWidget {
  final CombinedWeatherModel combinedWeatherModel;

  const TriHourGrid({Key? key, required this.combinedWeatherModel}) : super(key: key);

  @override
  State<TriHourGrid> createState() => _TriHourGridState();
}

class _TriHourGridState extends State<TriHourGrid> {
  final ScrollController _gridController = ScrollController();
  late final CombinedWeatherModel _combinedWeatherModel = widget.combinedWeatherModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            decoration: const BoxDecoration(
                border: Border(
              bottom: BorderSide(color: Colors.black, width: 1.0),
            )),
            child: const Text(
              "Daily 3 hour weather",
              style: TextStyle(fontSize: 34),
            ),
          ),
        ),
        Expanded(
          // flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
            child: GridView.count(
              controller: _gridController,
              physics: const BouncingScrollPhysics(),
              addAutomaticKeepAlives: false,
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              // mainAxisSpacing: 20.0,
              children: List.generate(
                _combinedWeatherModel.parsedTriHourWeatherModel!.length,
                (index) {
                  List<WeeklyWeatherModel> list =
                      _combinedWeatherModel.parsedTriHourWeatherModel![index];
                  // if (list == null) const SizedBox();

                  String date = DateFormat("d.M").format(list.first.dt!);
                  // String time = DateFormat("HH:mm").format(list.first.dt!);
                  String day = DateFormat("EEEE").format(list.first.dt!);

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TriHourWeather(
                          weeklyWeatherModel: list,
                        ),
                      ),
                    ),
                    child: Card(
                      // elevation: 11,
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        // height: 50,
                        // width: 150,
                        decoration: const BoxDecoration(
                          // gradient: RadialGradient(
                          gradient: LinearGradient(
                            colors: [
                              // Colors.yellow,
                              // Colors.orangeAccent,
                              // Colors.yellow.shade300,
                              // Color(0xFFE0C3FC),
                              Color(0xFFE0C3FC),
                              Color(0xFF8EC5FC),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              day,
                              style: const TextStyle(fontSize: 24),
                            ),
                            Text(
                              date,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
