import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Util {
  static void saveFavoriteCitiesToPrefs(String key, List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static void saveToPrefs(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  static Future loadFromPrefs(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static void clearPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int> checkSharedPreferencesMemoryUsage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getKeys().map((key) => prefs.get(key)).toList();
    final jsonData = json.encode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonData)).lengthInBytes;
    // print('Shared preferences data takes up $bytes bytes in memory');
    return bytes;
  }

  static void showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        // backgroundColor: const Color(0xFFC256F1),
      ),
    );
  }
}
