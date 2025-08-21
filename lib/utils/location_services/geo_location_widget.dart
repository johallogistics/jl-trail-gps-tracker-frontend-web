import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsTrackerWidget extends StatefulWidget {
  const GpsTrackerWidget({super.key});

  @override
  State<GpsTrackerWidget> createState() => _GpsTrackerWidgetState();
}

class _GpsTrackerWidgetState extends State<GpsTrackerWidget> {
  Position? _currentPosition;
  Stream<Position>? _positionStream;

  // Store records (you can later send this to API or DB)
  List<Map<String, dynamic>> locationRecords = [];

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, cannot request.");
    }

    // Start listening to location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update only if moved > 5 meters
      ),
    );

    _positionStream!.listen((Position position) {
      setState(() {
        _currentPosition = position;
        locationRecords.add({
          "latitude": position.latitude,
          "longitude": position.longitude,
          "timestamp": DateTime.now().toIso8601String(),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GPS Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentPosition != null)
              Text(
                "Lat: ${_currentPosition!.latitude}, "
                    "Lng: ${_currentPosition!.longitude}",
                style: const TextStyle(fontSize: 16),
              )
            else
              const Text("Fetching location..."),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: locationRecords.length,
                itemBuilder: (context, index) {
                  final record = locationRecords[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                        "Lat: ${record['latitude']}, Lng: ${record['longitude']}"),
                    subtitle: Text("Time: ${record['timestamp']}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
