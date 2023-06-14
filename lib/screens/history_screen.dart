import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/combined_weather_model.dart';

import '/screens/history_weather_screen.dart';

class WeatherHistoryScreen extends StatefulWidget {
  final bool locationPermission;
  final List<CombinedWeatherModel> previousSearches;

  const WeatherHistoryScreen(
      {Key? key, required this.locationPermission, required this.previousSearches})
      : super(key: key);

  @override
  State<WeatherHistoryScreen> createState() => _WeatherHistoryScreenState();
}

class _WeatherHistoryScreenState extends State<WeatherHistoryScreen>
    with AutomaticKeepAliveClientMixin<WeatherHistoryScreen> {
  // late final List<Map<String, dynamic>> _previousSearches =
  late final List<CombinedWeatherModel> _previousSearches = widget.previousSearches;
  bool _isNameAscending = true;
  bool _isDateAscending = true;
  bool _isTempAscending = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    // print("weatherhistory initstate");
  }

  @override
  bool get wantKeepAlive => true;

  void _sortList(String type) {
    setState(() {
      switch (type) {
        case "name":
          if (_isNameAscending) {
            _previousSearches.sort((a, b) => a.dailyWeatherModel!.currentCity
                .toString()
                .toLowerCase()
                .compareTo(b.dailyWeatherModel!.currentCity.toString().toLowerCase()));
            _isNameAscending = !_isNameAscending;
          } else {
            _previousSearches.sort((a, b) => b.dailyWeatherModel!.currentCity
                .toString()
                .toLowerCase()
                .compareTo(a.dailyWeatherModel!.currentCity.toString().toLowerCase()));
            _isNameAscending = !_isNameAscending;
          }
          break;
        case "date":
          if (_isDateAscending) {
            _previousSearches.sort((a, b) => (a.dailyWeatherModel!.dt as DateTime)
                .compareTo(b.dailyWeatherModel!.dt as DateTime));
            _isDateAscending = !_isDateAscending;
          } else {
            _previousSearches.sort((a, b) => (b.dailyWeatherModel!.dt as DateTime)
                .compareTo(a.dailyWeatherModel!.dt as DateTime));
            _isDateAscending = !_isDateAscending;
          }
          break;
        case "temp":
          if (_isTempAscending) {
            _previousSearches
                .sort((a, b) => (a.dailyWeatherModel!.temp!).compareTo(b.dailyWeatherModel!.temp!));
            _isTempAscending = !_isTempAscending;
          } else {
            _previousSearches
                .sort((a, b) => (b.dailyWeatherModel!.temp!).compareTo(a.dailyWeatherModel!.temp!));
            _isTempAscending = !_isTempAscending;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _previousSearches.isEmpty
        ? const Center(
            child: Text("No previous searches"),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 5.0),
                child: Text(
                  "Sort by",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => _sortList("name"),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.white)),
                    child: const Text("Name",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () => _sortList("date"),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.white)),
                    child: const Text("Date",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () => _sortList("temp"),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.white)),
                    child: const Text("Temp",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        )),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          // builder: (context) => HistoryWeatherScreen(weatherMap: _previousSearches[index]),
                          builder: (context) =>
                              HistoryWeatherScreen(combinedWeatherModel: _previousSearches[index]),
                        ),
                      ),
                      title: Text(
                        // _previousSearches[index]["daily"].currentCity,
                        _previousSearches[index].dailyWeatherModel!.currentCity,
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(DateFormat.MMMMEEEEd()
                          // .format(_previousSearches[index]["daily"].dt!)),
                          .format(_previousSearches[index].dailyWeatherModel!.dt!)),
                      trailing: Text(
                        // "${(_previousSearches[index]["daily"].temp!).round()}°C",
                        "${(_previousSearches[index].dailyWeatherModel!.temp!).round()}°C",
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  },
                  itemCount: _previousSearches.length,
                ),
              ),
            ],
          );
  }
}
