import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:weather_app/screens/weather.dart';
import 'package:weather_app/services/weather_service.dart';

import '../screens/history.dart';
import '../screens/settings.dart';
import 'daily_weather.dart';

class PageContainer extends StatefulWidget {
  final bool locationPermission;

  const PageContainer({Key? key, required this.locationPermission}) : super(key: key);

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  late final bool _locationPermission = widget.locationPermission;
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              label: "Settings", icon: Icon(Icons.settings)),
          BottomNavigationBarItem(label: "Weather", icon: Icon(Icons.cloud)),
          BottomNavigationBarItem(
              label: "History", icon: Icon(Icons.history_outlined)),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFE0C3FC),
        onTap: _onItemTapped,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                const Settings(),
                // Weather(locationPermission: _locationPermission),
                DailyWeather(locationPermission: _locationPermission),
                const WeatherHistory(),
              ],
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(onPressed: () => WeatherService.getWeeklyWeatherByCoords(65.0118734, 25.4716809)),
    );
  }
}
