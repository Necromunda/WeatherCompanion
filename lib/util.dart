import 'package:shared_preferences/shared_preferences.dart';


class Util {
  static void saveToPrefs(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.toString());
  }

  Future loadFromPrefs(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
}