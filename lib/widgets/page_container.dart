import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/weather_screen.dart';

import '../models/combined_weather_model.dart';

class PageContainer extends StatefulWidget {
  final bool locationPermission;

  const PageContainer({Key? key, required this.locationPermission})
      : super(key: key);

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  late final bool _locationPermission = widget.locationPermission;
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  // List<Map<String, dynamic>> _previousSearches = [];
  List<CombinedWeatherModel> _previousSearches = [];

  // void _addPreviousSearch(Map<String, dynamic> previousSearch) {
  void _addPreviousSearch(CombinedWeatherModel previousSearch) {
    setState(() {
      _previousSearches.add(previousSearch);
    });
  }

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
        selectedItemColor: const Color(0xFFE0C3FC),
        onTap: _onItemTapped,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                SettingsScreen(
                  locationPermission: _locationPermission,
                ),
                Weather(
                  locationPermission: _locationPermission,
                  addPreviousSearch: _addPreviousSearch,
                ),
                WeatherHistoryScreen(
                  locationPermission: _locationPermission,
                  previousSearches: _previousSearches,
                ),
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
    );
  }
}
