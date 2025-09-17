import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'device_utils.dart';

class LocationPostService {
  static const String baseUrl =
      'https://jl-trail-gps-tracker-backend-production.up.railway.app'; // Replace with your backend API

  StreamSubscription<Position>? positionStream;
  Timer? timer;
  Position? lastPosition;

  // Start tracking location with a timer every 5 seconds
  Future<void> startTracking() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance change to trigger updates
    );

    // Listen to location stream
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      lastPosition = position; // Store the latest position
    });

    // Use a Timer to send location every 5 seconds
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (lastPosition != null) {
        sendLocationToBackend(
            lastPosition!.latitude, lastPosition!.longitude);
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
  Future<void> sendLocationToBackend(double lat, double lng) async {
    try {
      final box = GetStorage();
      String? token = box.read('token');
      String? phone = box.read('phone');

      // defensive: ensure phone exists
      if (phone == null || phone.isEmpty) {
        debugPrint('sendLocationToBackend: phone not found in storage, skipping send');
        return;
      }
      // normalize phone if needed (ensure + prefix)
      if (!phone.startsWith('+')) phone = '+$phone';

      // device id for server-side checks
      // String? deviceId;
      // try {
      //   deviceId = await DeviceUtils.getDeviceId();
      // } catch (e) {
      //   debugPrint('sendLocationToBackend: DeviceUtils.getDeviceId error: $e');
      // }

      final payload = {
        'phone': phone,
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
        'isIdle': false,
        // if (deviceId != null) 'deviceId': deviceId,
      };

      debugPrint('sendLocationToBackend -> url: $baseUrl/api/driver-locations');
      debugPrint('sendLocationToBackend -> headers: token present=${token != null}');
      debugPrint('sendLocationToBackend -> body: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/driver-locations'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      debugPrint('sendLocationToBackend -> status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        // inspect returned JSON (server might return the saved object)
        try {
          final data = jsonDecode(response.body);
          debugPrint('Location send success, server returned: $data');
        } catch (_) {}
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized sending location (401). Token may be invalid.');
        // optional: try refresh token or force logout
      } else {
        debugPrint('Failed to send location: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('⚠️ Error sending location: $e');
    }
  }

}
