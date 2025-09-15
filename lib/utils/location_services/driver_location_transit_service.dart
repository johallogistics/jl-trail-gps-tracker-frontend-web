import 'dart:convert';
import 'package:http/http.dart' as http;

const String API_BASE = 'https://jl-trail-gps-tracker-backend-production.up.railway.app';

class DriverLocationTransitService {
  /// Get live location by phone.
  /// Handles both:
  ///  - { success: true, data: {...} }
  ///  - {...}  (raw location object)
  static Future<Map<String, dynamic>?> getLiveLocationByPhone(String phone) async {
    final url = Uri.parse('$API_BASE/location/$phone');
    final res = await http.get(url).timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);

    // Case 1: wrapped response { success: true, data: {...} }
    if (body is Map && body['success'] == true && body['data'] != null) {
      return Map<String, dynamic>.from(body['data']);
    }

    // Case 2: backend returns raw location object directly
    if (body is Map && body.containsKey('latitude') && body.containsKey('longitude')) {
      return Map<String, dynamic>.from(body);
    }

    // Unexpected shape
    return null;
  }

  /// Get ongoing transit by driverId.
  /// Accepts either raw object or wrapped { success, data } as well.
  static Future<Map<String, dynamic>?> getOngoingTransit(String driverId) async {
    final url = Uri.parse('$API_BASE/transits/ongoing/$driverId');
    final res = await http.get(url).timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);

    if (body == null) return null;

    // If wrapped: { success: true, data: {...} }
    if (body is Map && body['success'] == true && body['data'] != null) {
      final data = body['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    }

    // If raw transit object returned directly
    if (body is Map && body.containsKey('id') && body.containsKey('status')) {
      return Map<String, dynamic>.from(body);
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> fetchDrivers() async {
    final url = Uri.parse('$API_BASE/drivers-all');
    final res = await http.get(url).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);

    if (body is List) return List<Map<String, dynamic>>.from(body);
    if (body is Map && body['data'] is List) return List<Map<String, dynamic>>.from(body['data']);
    return [];
  }
}
