import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
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
  String _driverId = "0";


  String get driverId => _driverId;

  set driverId(String value) {
    _driverId = value;
  }

  Future<void> _checkActiveTrail() async {

    try {
      final response = await http.get(
        Uri.parse('https://jl-trail-gps-tracker-backend-production.up.railway.app/check-active-trail/$currentDriverId'),
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
