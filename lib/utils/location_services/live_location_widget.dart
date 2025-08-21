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

  @override
  void initState() {
    super.initState();
    _startLiveLocationUpdates();
  }

  Future<void> _fetchLiveLocation() async {
    try {
      // Replace with your API endpoint
      final response = await http.get(Uri.parse("https://yourapi.com/location"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          liveLocation = LatLng(
            (data["latitude"] as num).toDouble(),
            (data["longitude"] as num).toDouble(),
          );
        });

        // Move camera to new location
        _mapController.move(liveLocation, _mapController.zoom);
      } else {
        debugPrint("Failed to fetch location: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  void _startLiveLocationUpdates() {
    // Fetch first time immediately
    _fetchLiveLocation();

    // Then fetch every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchLiveLocation();
    });
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
          center: liveLocation,
          zoom: 12,
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
                builder: (context) => const Icon(
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
