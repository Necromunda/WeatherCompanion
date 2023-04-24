import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/frontpage.dart';
import 'package:weather_app/widgets/daily_weather.dart';
import 'package:weather_app/widgets/weekly_weather.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Weather companion",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         // colorScheme: ColorScheme(background: Colors.indigoAccent),
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    PermissionStatus locationStatus = await Permission.location.status;
    if (locationStatus != PermissionStatus.granted) {
      requestPermissions();
    }
  }

  Future<void> requestPermissions() async {
    PermissionStatus locationStatus = await Permission.location.request();
    if (locationStatus == PermissionStatus.denied) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weather companion",
      theme: ThemeData(
        primaryColor: const Color(0xFF8EC5FC),
        fontFamily: "Quicksand",
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 30.0,),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
      ),
      home: const Frontpage(),
    );
  }
}
