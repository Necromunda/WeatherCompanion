import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:weather_app/models/favorite_city_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/util.dart';

class SettingsScreen extends StatefulWidget {
  final bool locationPermission;

  const SettingsScreen({Key? key, required this.locationPermission})
      : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  final TextEditingController _textFieldController = TextEditingController();
  late final bool _locationPermission = widget.locationPermission;
  String? _hometown;
  bool _showTextfield = false;
  // List<FavoriteCityModel> _favoriteCities = [];
  // late final List<Map<String, dynamic>> elements = [
  //   {
  //     "group": "Application settings",
  //     "element": ExpansionTile(
  //       title: const Text('Set hometown'),
  //       leading: const Icon(Icons.home, color: Colors.green),
  //       children: <Widget>[
  //         ListTile(
  //           title: const Text("Current location"),
  //           trailing: _hometown == "current"
  //               ? const Icon(
  //                   Icons.home,
  //                   color: Colors.green,
  //                 )
  //               : null,
  //           onTap: () => _dropDownHandler("current"),
  //         ),
  //         ..._favoriteCities.map((city) {
  //           return ListTile(
  //               title: Text(city.name),
  //               trailing: _hometown != city.name
  //                   ? null
  //                   : const Icon(
  //                       Icons.home,
  //                       color: Colors.green,
  //                     ),
  //               onTap: () => _dropDownHandler(city.name));
  //         })
  //       ],
  //     ),
  //   },
  //   {
  //     "group": "Application settings",
  //     "element": ListTile(
  //       title: const Text("Clear cache"),
  //       leading: const Icon(Icons.delete, color: Colors.red),
  //       onTap: () async {
  //         Util.clearPrefs();
  //         Util.checkSharedPreferencesMemoryUsage().then((size) {
  //           Util.showSnackBar(context, "$size bytes cleared.");
  //         });
  //       },
  //     ),
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("settingsInitState");
  }

  void _initPlatformState() async {
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
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String? name = await WeatherService.getCityByCoords(pos);
    return name;
  }

  // Widget get _getExpansionTile {
  //   return ExpansionTile(
  //     title: const Text('Set hometown'),
  //     leading: const Icon(Icons.home, color: Colors.green),
  //     children: <Widget>[
  //       ListTile(
  //         title: const Text("Current location"),
  //         trailing: _hometown == "current"
  //             ? const Icon(
  //                 Icons.home,
  //                 color: Colors.green,
  //               )
  //             : null,
  //         onTap: () => _dropDownHandler("current"),
  //         enabled: !_locationPermission,
  //       ),
  //       ..._favoriteCities.map((city) {
  //         return ListTile(
  //             title: Text(city.name),
  //             trailing: _hometown != city.name
  //                 ? null
  //                 : const Icon(
  //                     Icons.home,
  //                     color: Colors.green,
  //                   ),
  //             onTap: () => _dropDownHandler(city.name));
  //       })
  //     ],
  //   );
  // }

  void _dropDownHandler(String? city) {
    if (city != null) Util.saveToPrefs("home", city);
    setState(() {
      _hometown = city ?? "Not set";
    });
  }

  TextField get _searchTextField {
    return TextField(
      autofocus: true,
      style: const TextStyle(color: Color(0xFFC256F1)),
      keyboardType: TextInputType.text,
      cursorColor: const Color(0xFFE0C3FC),
      controller: _textFieldController,
      decoration: InputDecoration(
        hintText: "City",
        suffixIcon: IconButton(
          onPressed: () {
            WeatherService.getCoordsByCity(_textFieldController.text).then((value) {
              print(value);
            });
            setState(() {
              // Navigator.pop(context);
            });
            _textFieldController.clear();
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
              subtitle: Text("Current: $_hometown"),
              leading: const Icon(Icons.home, color: Colors.green),
              children: <Widget>[
                ListTile(
                  title: const Text("Current location"),
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.blue,
                  ),
                  // trailing: _hometown == "current"
                  //     ? const Icon(
                  //         Icons.home,
                  //         color: Colors.green,
                  //       )
                  //     : null,
                  onTap: () {
                    // _dropDownHandler("current");
                    _getCurrentCityByPos().then((value) {
                      _dropDownHandler(value);
                    });
                  },
                  enabled: _locationPermission,
                ),
                ListTile(
                  // title: _showTextfield ? _searchTextField : const Text("Set your city"),
                  title: _searchTextField,
                  leading: const Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  // trailing: _hometown == "search"
                  //     ? const Icon(
                  //         Icons.home,
                  //         color: Colors.green,
                  //       )
                  //     : null,
                  onTap: () {
                    _showTextfield = !_showTextfield;
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
            child: ListTile(
              title: const Text("Clear cache"),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () async {
                Util.clearPrefs();
                Util.checkSharedPreferencesMemoryUsage().then((size) {
                  Util.showSnackBar(context, "$size bytes cleared.");
                });
              },
            ),
          ),
        ),
      ],
    );
    // return Padding(
    //   padding: const EdgeInsets.all(5),
    //   child: GroupedListView(
    //     elements: elements,
    //     groupBy: (element) => element["group"],
    //     groupSeparatorBuilder: (String value) => Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Text(
    //         value,
    //         textAlign: TextAlign.center,
    //         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //     itemBuilder: (c, element) {
    //       return Card(
    //         elevation: 8,
    //         margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    //         child: element["element"],
    //       );
    //     },
    //   ),
    // );
  }
}
