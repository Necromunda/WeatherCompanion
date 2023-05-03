import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:weather_app/util.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<String> _favoriteCities = [];
  String _hometown = "";
  late final List<Map<String, dynamic>> _elements = [
    {
      "group": "Application settings",
      "element": _getExpansionTile,
    },
    {
      "group": "Application settings",
      "element": ListTile(
        title: const Text("Clear cache"),
        leading: const Icon(Icons.delete, color: Colors.red),
        onTap: () async {
          Util.clearPrefs();
          Util.checkSharedPreferencesMemoryUsage().then((size) {
            Util.showSnackBar(context, "$size bytes cleared.");
          });
        },
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("settingsInitState");
  }

  void _initPlatformState() async {
    try {
      Util.loadFromPrefs("favoriteCities").then((value) {
        if (value != null) {
          print(value);
          List<dynamic> jsonList = jsonDecode(value) as List<dynamic>;
          setState(() {
            _favoriteCities = jsonList.map((e) => e as String).toList();
            _elements[0]["element"] = _getExpansionTile;
          });
        }
      });
      print(_favoriteCities);
    } catch (e, stackTrace) {
      debugPrint("$e, $stackTrace");
    }
  }

  Widget get _getExpansionTile {
    return ExpansionTile(
      title: const Text('Set hometown'),
      leading: const Icon(Icons.home, color: Colors.green),
      children: <Widget>[
        ..._favoriteCities.map((city) {
          return ListTile(
              title: Text(city),
              trailing: _hometown != city
                  ? null
                  : const Icon(
                      Icons.home,
                      color: Colors.green,
                    ),
              onTap: () => _dropDownHandler(city));
        })
      ],
    );
  }

  void _dropDownHandler(String city) {
    setState(() {
      _hometown = city;
      _elements[0]["element"] = _getExpansionTile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GroupedListView(
        elements: _elements,
        groupBy: (element) => element["group"],
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        itemBuilder: (c, element) {
          return Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: element["element"],
          );
        },
      ),
    );
  }
}
