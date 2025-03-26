import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/admin/locations_model.dart';

class LocationService {
  static const String baseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app/api/locations';

  Future<List<Location>> fetchLocations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];

        // Map the list of JSON objects to a list of Location instances
        return data.map((item) => Location.fromJson(item)).toList();
      } else {
        throw Exception('Failed to fetch locations');
      }
    } else {
      throw Exception('Failed to load locations: ${response.statusCode}');
    }
  }
}
