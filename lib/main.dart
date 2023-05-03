import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:weather_app/widgets/page_container.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Widget get _waitingPermissions {
    return ScaffoldGradientBackground(
      resizeToAvoidBottomInset: false,
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF8EC5FC),
          Color(0xFFE0C3FC),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCB9FC),
        title: const Text("Weather companion"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 75,
              height: 75,
              child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                colors: [Colors.white],
                strokeWidth: 2,
              ),
            ),
            Text("Waiting permissions"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weather companion",
      theme: ThemeData(
        // primaryColor: const Color(0xFF8EC5FC),
        primaryColor: const Color(0xFFE0C3FC),
        fontFamily: "Quicksand",
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(
            fontSize: 30.0,
          ),
          bodyMedium: TextStyle(fontSize: 14.0),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: _handleLocationPermission(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                // decoration:
                // BoxDecoration(border: Border.all(color: Colors.red)),
                child: PageContainer(locationPermission: snapshot.data!),
              );
            }
            return _waitingPermissions;
          }),
    );
  }
}
