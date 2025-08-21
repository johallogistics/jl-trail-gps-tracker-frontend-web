// lib/services/sign_off_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sign_off_models/sign_off.dart';

class SignOffService {
  final String baseUrl; // e.g., http://localhost:3000
  SignOffService(this.baseUrl);

  Future<Map<String, dynamic>> create(SignOff body) async {
    final res = await http.post(Uri.parse('$baseUrl/signoffs'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(body.toJson()),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('Create failed: ${res.body}');
  }

  Future<Map<String, dynamic>> list({int page = 1, int pageSize = 20, String? search}) async {
    final qs = {
      'page': '$page', 'pageSize': '$pageSize', if (search != null && search.isNotEmpty) 'search': search
    };
    final uri = Uri.parse('$baseUrl/signoffs').replace(queryParameters: qs);
    final res = await http.get(uri);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('List failed');
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/signoffs/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Get failed');
  }

  Future<Map<String, dynamic>> update(int id, SignOff body) async {
    final res = await http.put(Uri.parse('$baseUrl/signoffs/$id'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode(body.toJson()),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Update failed: ${res.body}');
  }

  Future<void> remove(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/signoffs/$id'));
    if (res.statusCode != 204) throw Exception('Delete failed');
  }
}