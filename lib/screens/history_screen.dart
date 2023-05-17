import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/daily_weather_model.dart';
import '/screens/history_weather_screen.dart';

class WeatherHistoryScreen extends StatefulWidget {
  final bool locationPermission;
  final List<Map<String, dynamic>> previousSearches;
  // final List<DailyWeatherModel> previousSearches;

  const WeatherHistoryScreen(
      {Key? key,
      required this.locationPermission,
      required this.previousSearches})
      : super(key: key);

  @override
  State<WeatherHistoryScreen> createState() => _WeatherHistoryScreenState();
}

class _WeatherHistoryScreenState extends State<WeatherHistoryScreen>
    with AutomaticKeepAliveClientMixin<WeatherHistoryScreen> {
  late final List<Map<String, dynamic>> _previousSearches =
  // late final List<DailyWeatherModel> _previousSearches =
      widget.previousSearches;
  bool _nameAscending = true;
  bool _dateAscending = true;
  bool _tempAscending = true;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    print("weatherhistory initstate");
  }

  @override
  bool get wantKeepAlive => true;

  void _sortList(String type) {
    setState(() {
      switch (type) {
        case "name":
          if (_nameAscending) {
            // _previousSearches.sort((a, b) => a["name"]
            _previousSearches.sort((a, b) => a["daily"].currentCity
                .toString()
                .toLowerCase()
                // .compareTo(b["name"].toString().toLowerCase()));
                .compareTo(b["daily"].currentCity.toString().toLowerCase()));
            _nameAscending = !_nameAscending;
          } else {
            // _previousSearches.sort((a, b) => b["name"]
            _previousSearches.sort((a, b) => b["daily"].currentCity
                .toString()
                .toLowerCase()
                // .compareTo(a["name"].toString().toLowerCase()));
                .compareTo(a["daily"].currentCity.toString().toLowerCase()));
            _nameAscending = !_nameAscending;
          }
          break;
        case "date":
          if (_dateAscending) {
            _previousSearches.sort((a, b) =>
                // (a["date"] as DateTime).compareTo(b["date"] as DateTime));
                (a["daily"].dt as DateTime).compareTo(b["daily"].dt as DateTime));
            _dateAscending = !_dateAscending;
          } else {
            _previousSearches.sort((a, b) =>
                // (b["date"] as DateTime).compareTo(a["date"] as DateTime));
                (b["daily"].dt as DateTime).compareTo(a["daily"].dt as DateTime));
            _dateAscending = !_dateAscending;
          }
          break;
        case "temp":
          if (_tempAscending) {
            _previousSearches.sort(
                // (a, b) => (a["temp"] as double).compareTo(b["temp"] as double));
                (a, b) => (a["daily"].temp!).compareTo(b["daily"].temp!));
            _tempAscending = !_tempAscending;
          } else {
            _previousSearches.sort(
                // (a, b) => (b["temp"] as double).compareTo(a["temp"] as double));
                (a, b) => (b["daily"].temp!).compareTo(a["daily"].temp!));
            _tempAscending = !_tempAscending;
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
                        side:
                            const BorderSide(width: 1.0, color: Colors.white)),
                    child: const Text("Name",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () => _sortList("date"),
                    style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(width: 1.0, color: Colors.white)),
                    child: const Text("Date",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () => _sortList("temp"),
                    style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(width: 1.0, color: Colors.white)),
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
                      onTap: 
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryWeatherScreen(weatherMap: _previousSearches[index]),
                      ),),
                      title: Text(
                        // _previousSearches[index]["name"],
                        _previousSearches[index]["daily"].currentCity,
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(DateFormat.MMMMEEEEd()
                          .format(_previousSearches[index]["daily"].dt!)),
                      trailing: Text(
                        "${(_previousSearches[index]["daily"].temp!).round()}°C",
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
