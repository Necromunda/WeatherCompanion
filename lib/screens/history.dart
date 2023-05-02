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

  const WeatherHistory({Key? key, required this.locationPermission})
      : super(key: key);

  @override
  State<WeatherHistory> createState() => _WeatherHistoryState();
}

class _WeatherHistoryState extends State<WeatherHistory>
    with AutomaticKeepAliveClientMixin<WeatherHistory> {
  late final bool _locationPermission = widget.locationPermission;
  late Position? _currentPos = null;

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
    print(_currentPos);
    return Center(
      child: _locationPermission == false
          ? const Text("Location not available")
          : _currentPos == null
              ? const Text("Loading map ...")
              : FlutterMap(
                  options: MapOptions(
                    center: LatLng(65.061107, 25.473964),
                    // _currentPos!.latitude, _currentPos!.longitude),
                    zoom: 6,
                    maxZoom: 15,
                    minZoom: 4,
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                  nonRotatedChildren: const [
                    // AttributionWidget.defaultWidget(
                    //   source: 'OpenStreetMap contributors',
                    //   onSourceTapped: null,
                    // ),
                  ],
                  children: [
                    // TileLayer(
                    //   urlTemplate:
                    //   "https://stamen-tiles.a.ssl.fastly.net/toner-background/{z}/{x}/{y}.png",
                    //   userAgentPackageName: 'com.jrantapaa.weather_app',
                    // ),
                    TileLayer(
                      opacity: 1,
                      // backgroundColor: Colors.black,
                      urlTemplate:
                          "https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=${WeatherService.apiKey}",
                      userAgentPackageName: 'com.jrantapaa.weather_app',
                    ),
                    // TileLayer(
                    //   urlTemplate:
                    //       'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    //   userAgentPackageName: 'com.jrantapaa.weather_app',
                    // ),
                    // TileLayerOptions(
                    //   urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    //   subdomains: ['a', 'b', 'c'],
                    //   attributionBuilder: (_) {
                    //     return Text('© OpenStreetMap contributors');
                    //   },
                    // ),
                    // GeoJSONLayerOptions(
                    //   // URL to the GeoJSON file containing the country borders
                    //   url: 'https://d2ad6b4ur7yvpq.cloudfront.net/naturalearth-3.3.0/ne_50m_admin_0_boundary_lines_land.geojson',
                    //   // Use the "name" property of each feature as the label
                    //   // for the country borders
                    //   nameProperty: 'name',
                    //   // Style the country borders with a red color and
                    //   // a thickness of 1.0
                    //   style: GeoJsonStyleOptions(
                    //     color: Colors.red,
                    //     strokeWidth: 1.0,
                    //   ),
                    // ),
                    MarkerLayer(
                      markers: [
                        buildMarker(
                            LatLng(
                                _currentPos!.latitude, _currentPos!.longitude),
                            "You're here"),
                        // buildMarker(LatLng(55.3781, -3.4360), "Love"), // England
                        // buildMarker(LatLng(46.2276, 2.2137), "Aimer"), // France
                        // buildMarker(LatLng(52.1326, 5.2913), "Liefde"), // Netherlands
                        // buildMarker(LatLng(51.1657, 10.4515), "Liebe"), // Germany
                      ],
                    )
                  ],
                ),
    );
  }
}
