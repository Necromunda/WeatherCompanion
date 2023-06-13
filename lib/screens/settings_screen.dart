import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../util.dart';

import '../services/weather_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool locationPermission;

  const SettingsScreen({Key? key, required this.locationPermission}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  static const List<String> _availableLocales = ["English", "Finnish"];
  String? _currentLocale;
  final TextEditingController _textFieldController = TextEditingController();
  late final bool _locationPermission = widget.locationPermission;
  String? _hometown;
  late bool _showTextfield;
  DateTime? _lastRequest;
  final int _timeBetweenRequests = 5;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    // print("settingsInitState");
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _initPlatformState() async {
    // String locale = await Util.loadFromPrefs("locale");

    setState(() {
      Util.loadFromPrefs("locale").then((value) => _currentLocale = value);
      // _currentLocale = locale;
      _showTextfield = false;
    });
    _getHometown().then((value) async {
      if (value == null && _locationPermission) {
        final name = await _getCurrentCityByPos();
        Util.saveToPrefs("home", name);
        setState(() {
          _hometown = name ?? "Not set";
        });
      } else {
        setState(() {
          _hometown = value ?? "Not set";
          // _lastRequest = DateTime.now();
        });
      }
    });
    // _getFavoriteCities();
  }

  Future<String?> _getHometown() async {
    try {
      final value = await Util.loadFromPrefs("home");
      // print(value);
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  // void _getFavoriteCities() {
  //   try {
  //     Util.loadFromPrefs("favoriteCities").then((value) {
  //       if (value != null) {
  //         List<dynamic> jsonList = jsonDecode(value) as List<dynamic>;
  //         setState(() {
  //           _favoriteCities = jsonList
  //               .map((e) => FavoriteCityModel.createFavoriteCity(e))
  //               .toList();
  //         });
  //       }
  //     });
  //   } catch (e, stackTrace) {
  //     debugPrint("$e, $stackTrace");
  //   }
  // }

  Future<String?> _getCurrentCityByPos() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // print(pos);
    String? name = await WeatherService.getCityByCoords(pos.latitude, pos.longitude);
    return name;
  }

  bool _allowRequest() {
    DateTime now = DateTime.now();
    if (_lastRequest == null) {
      setState(() {
        _lastRequest = DateTime.now();
      });
      return true;
    }
    Duration difference = now.difference(_lastRequest!);

    if (difference >= Duration(seconds: _timeBetweenRequests)) {
      setState(() {
        _lastRequest = now;
      });
      return true;
    } else {
      return false;
    }
  }

  void _dropDownHandler(String? city) {
    if (city != null) Util.saveToPrefs("home", city);
    setState(() {
      _hometown = city ?? "Not set";
    });
  }

  TextField get _searchTextField {
    return TextField(
      maxLength: 30,
      autofocus: true,
      style: const TextStyle(color: Color(0xFFC256F1)),
      keyboardType: TextInputType.text,
      cursorColor: const Color(0xFFE0C3FC),
      controller: _textFieldController,
      onTapOutside: (_) {
        setState(() {
          _showTextfield = !_showTextfield;
          _textFieldController.clear();
        });
      },
      decoration: InputDecoration(
        hintText: "City",
        suffixIcon: IconButton(
          onPressed: () {
            bool res = _allowRequest();
            if (res) {
              WeatherService.getCoordsByCity(_textFieldController.text).then((value) {
                // print(value);
                if (value != null) {
                  // Position pos = Position(
                  //     longitude: value["lon"]!,
                  //     latitude: value["lat"]!,
                  //     timestamp: DateTime.now(),
                  //     accuracy: 0.0,
                  //     altitude: 0.0,
                  //     heading: 0.0,
                  //     speed: 0.0,
                  //     speedAccuracy: 0.0);
                  WeatherService.getCityByCoords(value["lat"]!, value["lon"]!).then((value) {
                    setState(() {
                      _hometown = value;
                    });
                    Util.saveToPrefs("home", value);
                  });
                }
              });
              setState(() {
                _showTextfield = !_showTextfield;
                _textFieldController.clear();
              });
            } else {
              Util.showSnackBar(context, "Please wait $_allowRequestIn seconds between requests");
            }
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
    );
  }

  int get _allowRequestIn =>
      _timeBetweenRequests - DateTime.now().difference(_lastRequest ?? DateTime.now()).inSeconds;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0),
          child: Card(
            elevation: 8,
            child: ExpansionTile(
              title: const Text('Set hometown'),
              subtitle: Text("Current: ${_hometown ?? "Not set"}"),
              leading: const Icon(Icons.home, color: Colors.green),
              children: <Widget>[
                ListTile(
                  title: const Text("Current location"),
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    bool res = _allowRequest();
                    if (res) {
                      _getCurrentCityByPos().then((value) {
                        _dropDownHandler(value);
                      });
                    } else {
                      Util.showSnackBar(
                          context, "Please wait $_allowRequestIn seconds between requests");
                    }
                  },
                  enabled: _locationPermission,
                ),
                ListTile(
                  title: _showTextfield ? _searchTextField : const Text("Set your city"),
                  leading: const Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  onTap: () {
                    setState(() {
                      _showTextfield = !_showTextfield;
                    });
                  },
                ),
                // ExpansionTile(
                //   title: const Text("Select from favorites"),
                //   children: [
                //     ..._favoriteCities.map(
                //       (city) {
                //         return ListTile(
                //             title: Text(city.name),
                //             trailing: _hometown != city.name
                //                 ? null
                //                 : const Icon(
                //                     Icons.home,
                //                     color: Colors.green,
                //                   ),
                //             onTap: () => _dropDownHandler(city.name));
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0),
          child: Card(
            elevation: 8,
            child: ExpansionTile(
              title: const Text("Change language"),
              leading: const Icon(
                Icons.language,
                color: Colors.blue,
              ),
              children: [
                ..._availableLocales.map(
                  (e) {
                  // print(_currentLocale);
                    return ListTile(
                        // enabled: false,
                        title: Text(e),
                        leading: const Icon(
                          Icons.short_text,
                          color: Colors.blue,
                        ),
                        trailing: e != _currentLocale
                            ? null
                            : const Icon(
                                Icons.fingerprint,
                                color: Colors.green,
                              ),
                        onTap: () {
                          setState(() {
                            _currentLocale = e;
                          });
                          Util.saveToPrefs("locale", e);
                          Util.showSnackBar(context, "Language set to: $e");
                        });
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 10.0, right: 10.0),
          child: Card(
            elevation: 8,
            child: ListTile(
              title: const Text("Clear cache"),
              leading: const Icon(Icons.delete, color: Colors.red),
              // onTap: () async {
              onTap: () {
                setState(() {
                  _hometown = null;
                });
                Util.clearPrefs();
                Util.showSnackBar(context, "Cache cleared");
                // Util.checkSharedPreferencesMemoryUsage().then((size) {
                //   Util.showSnackBar(context, "$size bytes cleared.");
                // });
              },
            ),
          ),
        ),
      ],
    );
  }
}
