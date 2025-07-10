import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:trail_tracker/api/api_manager.dart';

import '../../models/admin/driver_model.dart';
import '../../models/admin/locations_model.dart';

class DashboardRepository {
  static const String baseUrl =
      'https://jl-trail-gps-tracker-backend-production.up.railway.app';

  static Future<Map<String, dynamic>> fetchStats() async {
    final response = await ApiManager.get('dashboard/counts');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load drivers');
    }
  }
}
