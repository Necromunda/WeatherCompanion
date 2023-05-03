import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WeatherHistory extends StatefulWidget {
  final bool locationPermission;
  final List<Map<String, dynamic>> previousSearches;

  const WeatherHistory(
      {Key? key,
      required this.locationPermission,
      required this.previousSearches})
      : super(key: key);

  @override
  State<WeatherHistory> createState() => _WeatherHistoryState();
}

class _WeatherHistoryState extends State<WeatherHistory>
    with AutomaticKeepAliveClientMixin<WeatherHistory> {
  late final bool _locationPermission = widget.locationPermission;
  late final List<Map<String, dynamic>> _previousSearches =
      widget.previousSearches;
  late Position? _currentPos = null;
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
    // _initPlatformState();
    print("weatherhistory initstate");
  }

  // void _initPlatformState() async {
  //   _currentPos = await _getCurrentPosition();
  //   setState(() {});
  // }
  //
  // Future<Position?> _getCurrentPosition() async {
  //   if (!_locationPermission) return null;
  //   return Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }

  @override
  bool get wantKeepAlive => true;

  void _sortList(String type) {
    setState(() {
      switch (type) {
        case "name":
          if (_nameAscending) {
            _previousSearches.sort((a, b) => a["name"]
                .toString()
                .toLowerCase()
                .compareTo(b["name"].toString().toLowerCase()));
            _nameAscending = !_nameAscending;
          } else {
            _previousSearches.sort((a, b) => b["name"]
                .toString()
                .toLowerCase()
                .compareTo(a["name"].toString().toLowerCase()));
            _nameAscending = !_nameAscending;
          }
          break;
        case "date":
          if (_dateAscending) {
            _previousSearches.sort((a, b) =>
                (a["date"] as DateTime).compareTo(b["date"] as DateTime));
            _dateAscending = !_dateAscending;
          } else {
            _previousSearches.sort((a, b) =>
                (b["date"] as DateTime).compareTo(a["date"] as DateTime));
            _dateAscending = !_dateAscending;
          }
          break;
        case "temp":
          if (_tempAscending) {
            _previousSearches.sort(
                (a, b) => (a["temp"] as double).compareTo(b["temp"] as double));
            _tempAscending = !_tempAscending;
          } else {
            _previousSearches.sort(
                (a, b) => (b["temp"] as double).compareTo(a["temp"] as double));
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
                      onTap: null,
                      // () => Navigator.push(
                      // context,
                      // MaterialPageRoute(
                      //   builder: (context) => Settings(),
                      // )),
                      title: Text(
                        _previousSearches[index]["name"],
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(DateFormat.MMMMEEEEd()
                          .format(_previousSearches[index]["date"])),
                      trailing: Text(
                        "${(_previousSearches[index]["temp"] as double).round()}°C",
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
