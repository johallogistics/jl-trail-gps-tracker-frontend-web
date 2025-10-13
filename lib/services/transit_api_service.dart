// lib/services/transit_api_service.dart

import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class TransitApiService {
  // Use the actual URL of your deployed Fastify backend
  static const String BASE_URL = 'https://jl-trail-gps-tracker-backend-production.up.railway.app/api';

  // NOTE: This call will use the *existing* DriverLocationTransitService
  // as it is assumed to be a custom backend service, not the Google API.
  // We don't need to rewrite it here, just focus on the Maps APIs.

  /// Calls the server-side proxy for Google Directions API.
  Future<Map<String, dynamic>> fetchDirectionsProxy(
      LatLng start, LatLng dest) async {
    final url = Uri.parse('$BASE_URL/directions');

    // Server expects origin and destination strings (e.g., "13.08,80.27")
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'origin': '${start.latitude},${start.longitude}',
        'destination': '${dest.latitude},${dest.longitude}',
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // The server itself is reporting an error (e.g., Fastify failed to call Google)
      final errorBody = json.decode(response.body);
      throw Exception(
          'Proxy Directions API failed (Status ${response.statusCode}): ${errorBody['error'] ?? response.reasonPhrase}');
    }
  }

  /// Calls the server-side proxy for Google Distance Matrix API.
  Future<Map<String, dynamic>> fetchDistanceMatrixProxy(
      LatLng origin, LatLng dest) async {
    final url = Uri.parse('$BASE_URL/distancematrix');

    // Server expects origins and destinations strings
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'origins': ['${origin.latitude},${origin.longitude}'],
        'destinations': ['${dest.latitude},${dest.longitude}'],
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
          'Proxy Distance Matrix API failed (Status ${response.statusCode}): ${errorBody['error'] ?? response.reasonPhrase}');
    }
  }
}