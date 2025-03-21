import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import '../views/widgets/map_usecase_code.dart';

class TrailController extends GetxController {
  // Assuming you have a way to get the current driver ID (e.g., from authentication)
  final String currentDriverId = '1'; // Replace with actual driver ID

  // Observable RxBool to track active trail status
  var hasActiveTrail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startTrackingLocation();
    // Only initialize Workmanager on Android/iOS
    if (!kIsWeb) {
      try {
        Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: true,
        );
        print("Workmanager initialized successfully!");
      } catch (e) {
        print("Error initializing Workmanager: $e");
      }
    } else {
      print("Workmanager is not supported on this platform");
    }
  }

  Position? _currentPosition;
  bool _isTracking = true;
  String _driverId = "0";


  String get driverId => _driverId;

  set driverId(String value) {
    _driverId = value;
  }

  void _startTrackingLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
        _currentPosition = position;
      _sendLocationToServer(position.latitude, position.longitude);
    });
  }

  void _stopTrackingLocation() {
      _isTracking = false;
  }

  void _sendLocationToServer(double latitude, double longitude) async {
    final String apiUrl = 'http://localhost:3000/location';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "driverId": 6,
        "latitude": latitude,
        "longitude": longitude,
        "isIdle": false
      },
    );

    if (response.statusCode == 200) {
      print('Location updated successfully');
    } else {
      print('Failed to update location');
    }
  }


  Future<void> _checkActiveTrail() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/check-active-trail/$currentDriverId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        hasActiveTrail.value = data['hasActiveTrail'];
      } else {
        throw Exception('Failed to check active trail');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
