import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

// import 'package:latlong2/latlong.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

class WeatherHistory extends StatefulWidget {
  final bool locationPermission;
  final List<Map<String, dynamic>> previousSearches;

  const WeatherHistory(
      {Key? key,
      required this.locationPermission,
      required this.previousSearches})
      : super(key: key);

  @override
  State<WeatherHistory> createState() => _WeatherHistoryState();
}

class _WeatherHistoryState extends State<WeatherHistory>
    with AutomaticKeepAliveClientMixin<WeatherHistory> {
  late final bool _locationPermission = widget.locationPermission;
  late final List<Map<String, dynamic>> _previousSearches =
      widget.previousSearches;
  late Position? _currentPos = null;
  GeoJsonParser myGeoJson = GeoJsonParser();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    print("weatherhistory initstate");
  }

  void _initPlatformState() async {
    _currentPos = await _getCurrentPosition();
    setState(() {});
  }

  Future<Position?> _getCurrentPosition() async {
    if (!_locationPermission) return null;
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  TextStyle getDefaultTextStyle() {
    return const TextStyle(
      fontSize: 20,
      backgroundColor: Colors.black,
      color: Colors.white,
    );
  }

  Container buildTextWidget(String word) {
    return Container(
        alignment: Alignment.center,
        child: Text(word,
            textAlign: TextAlign.center, style: getDefaultTextStyle()));
  }

  Marker buildMarker(LatLng coordinates, String word) {
    return Marker(
        point: coordinates,
        width: 100,
        height: 25,
        builder: (context) => buildTextWidget(word));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return _previousSearches.isEmpty
        ? const Center(
            child: Text("No previous searches"),
          )
        : ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                onTap: null,
                title: Text(
                  _previousSearches[index]["name"],
                  style: const TextStyle(fontSize: 20),
                ),
                trailing: Text(
                  "${(_previousSearches[index]["temp"] as double).round()}°C",
                  style: const TextStyle(fontSize: 20),
                ),
              );
            },
            itemCount: _previousSearches.length,
          );
    // return Center(
    //   child: _locationPermission == false
    //       ? const Text("Location not available")
    //       : _currentPos == null
    //           ? const Text("Loading map ...")
    //           : FlutterMap(
    //               options: MapOptions(
    //                 center: LatLng(65.061107, 25.473964),
    //                 // _currentPos!.latitude, _currentPos!.longitude),
    //                 zoom: 6,
    //                 maxZoom: 15,
    //                 minZoom: 4,
    //                 interactiveFlags:
    //                     InteractiveFlag.pinchZoom | InteractiveFlag.drag,
    //               ),
    //               nonRotatedChildren: const [
    //                 // AttributionWidget.defaultWidget(
    //                 //   source: 'OpenStreetMap contributors',
    //                 //   onSourceTapped: null,
    //                 // ),
    //               ],
    //               children: [
    //                 // TileLayer(
    //                 //   urlTemplate:
    //                 //   "https://stamen-tiles.a.ssl.fastly.net/toner-background/{z}/{x}/{y}.png",
    //                 //   userAgentPackageName: 'com.jrantapaa.weather_app',
    //                 // ),
    //                 TileLayer(
    //                   opacity: 1,
    //                   // backgroundColor: Colors.black,
    //                   urlTemplate:
    //                       "https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=${WeatherService.apiKey}",
    //                   userAgentPackageName: 'com.jrantapaa.weather_app',
    //                 ),
    //                 MarkerLayer(
    //                   markers: [
    //                     buildMarker(
    //                         LatLng(
    //                             _currentPos!.latitude, _currentPos!.longitude),
    //                         "You're here"),
    //                   ],
    //                 )
    //               ],
    //             ),
    // );
  }
}
