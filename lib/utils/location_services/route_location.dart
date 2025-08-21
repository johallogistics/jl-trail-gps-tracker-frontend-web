import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'live_location_widget.dart';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({super.key});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  final MapController _mapController = MapController();

  LatLng start = LatLng(13.0827, 80.2707); // Chennai
  LatLng end = LatLng(12.9716, 77.5946); // Bangalore
  LatLng? liveLocation;

  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        liveLocation = LatLng(10.7905, 78.7047); // Example: near Bangalore
      });
    });
  }

  Future<void> _fetchRoute() async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final coords =
      data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

      setState(() {
        routePoints =
            coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
      });
    } else {
      print('Error fetching route: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route between two points")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            center: start,
            zoom: 13.0
        ),
        children: [
          // ✅ Tile Layer
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),

          // ✅ Marker Layer
          MarkerLayer(
            markers: [
              Marker(
                point: start,
                width: 40,
                height: 40,
                builder: (BuildContext context) {
                  return const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 40,
                  );
                },
              ),
              Marker(
                point: end,
                width: 40,
                height: 40,
                builder: (BuildContext context) {
                  return const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  );
                },
              ),
            ],
          ),
          // ✅ Polyline Layer
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
          if (liveLocation != null)
            LiveLocationPage(),
        ],
      ),
    );
  }
}
