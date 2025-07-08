import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:trail_tracker/api/api_manager.dart';

import '../../models/admin/driver_model.dart';
import '../../models/admin/locations_model.dart';

class DriverRepository {
  static const String baseUrl =
      'https://jl-trail-gps-tracker-backend-production.up.railway.app';

  Future<Map<String, dynamic>> addDriver(
      Map<String, dynamic> driverData) async {
    final url = Uri.parse('$baseUrl/drivers');
    try {
      print("DRIVER DATA $driverData");
      final response = await ApiManager.post('drivers', driverData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Driver added successfully',
          'data': jsonDecode(response.body)
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add driver: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// ✅ Fetch drivers API call
  static Future<Map<String, dynamic>> fetchDrivers() async {
    final response = await ApiManager.get('drivers-all');
    if (response.statusCode == 200) {
      /// ✅ Return the full JSON object, not just the list
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load drivers');
    }
  }

  // ✅ Fetch location by phone number
  Future<Location?> fetchDriverLocation(String phone) async {
    // final storage = GetStorage();
    // final token = storage.read('token');
    try {
      final response = await ApiManager.get('api/driverLocation/$phone');
      if (response.statusCode == 200) {
        final Map<String, dynamic>? jsonResponse =
            json.decode(response.body)['data'];

        if (jsonResponse != null) {
          return Location.fromJson(jsonResponse);
        } else {
          print("❌ No location data found");
          return null;
        }
      } else {
        print('❌ Failed to load location: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }

  /// Update Driver
  Future<bool> updateDriver(String id, Driver driver) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final response = await http.put(
      Uri.parse("$baseUrl/drivers/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(driver.toJson()),
    );

    return response.statusCode == 200;
  }

  /// Delete Driver
  Future<bool> deleteDriver(String id) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final response =
        await http.delete(Uri.parse("$baseUrl/drivers/$id"), headers: {
      'Authorization': 'Bearer $token'
    });

    return response.statusCode == 200;
  }
}
