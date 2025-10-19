import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LiveLocationPage extends StatefulWidget {
  const LiveLocationPage({super.key});

  @override
  State<LiveLocationPage> createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  final MapController _mapController = MapController();
  LatLng liveLocation = LatLng(13.0827, 80.2707); // Default (Chennai)
  Timer? _timer;

  static const String baseUrl =
      "https://jl-trail-gps-tracker-backend-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    _startLiveLocationUpdates();
  }

  Future<void> _fetchLiveLocation() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/location"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newLocation = LatLng(
          (data["latitude"] as num).toDouble(),
          (data["longitude"] as num).toDouble(),
        );

        setState(() {
          liveLocation = newLocation;
        });

        // Move camera smoothly to new location
        _mapController.move(liveLocation, _mapController.camera.zoom);
      } else {
        debugPrint("Failed to fetch location: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  void _startLiveLocationUpdates() {
    _fetchLiveLocation(); // Fetch immediately
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchLiveLocation());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Location Tracking")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: liveLocation,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: liveLocation,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
