import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPostService {
  static const String baseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app';  // Replace with your backend API

  StreamSubscription<Position>? positionStream;
  Timer? timer;
  Position? lastPosition;

  // Start tracking location with a timer every 5 seconds
  Future<void> startTracking(String phone) async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance change to trigger updates
    );

    // Listen to location stream
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lastPosition = position;  // Store the latest position
    });

    // Use a Timer to send location every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (lastPosition != null) {
        sendLocationToBackend(phone, lastPosition!.latitude, lastPosition!.longitude);
      }
    });

    print("✅ Location tracking started");
  }

  // Stop tracking location
  void stopTracking() {
    positionStream?.cancel();
    timer?.cancel();
    print("🛑 Location tracking stopped");
  }

  // Send location to backend
  Future<void> sendLocationToBackend(String phone, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/driver-locations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'latitude': lat,
          'longitude': lng,
          'timestamp': DateTime.now().toIso8601String(),
          "isIdle" : false
        }),
      );

      if (response.statusCode == 200) {
        print("📍 Location sent: $lat, $lng");
      } else {
        print("❌ Failed to send location: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error sending location: $e");
    }
  }
}
