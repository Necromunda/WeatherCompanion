import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';


class Util {
  static void saveToPrefs(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.toString());
  }

  Future loadFromPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
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