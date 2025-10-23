import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  static const String baseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app';


  static Map<String, String> _headers() {
    final storage = GetStorage();
    final token = storage.read('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json', // ✅ Ensures JSON response
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// GET request with Uri (supports query parameters)
  static Future<http.Response> getUri(Uri uri) async {
    // Combine the base URL with the provided path/query
    final fullUri = Uri.parse(baseUrl).resolveUri(uri);
    return await http.get(fullUri, headers: _headers());
  }


  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // ✅ Send JSON data
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body), // ✅ Convert body to JSON
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

}
