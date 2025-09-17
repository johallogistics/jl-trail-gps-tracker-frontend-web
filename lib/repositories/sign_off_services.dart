// lib/services/sign_off_service.dart
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sign_off_models/sign_off.dart';

class SignOffService {
  final String baseUrl; // e.g., https://jl-trail-gps-tracker-backend-production.up.railway.app
  SignOffService(this.baseUrl);

  Future<SignOff> create(SignOff body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signOffs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body.toJson()),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return SignOff.fromJson(jsonDecode(res.body));
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

  Future<SignOff> update(int id, SignOff body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/signoffs/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body.toJson()),
    );
    if (res.statusCode == 200) {
      return SignOff.fromJson(jsonDecode(res.body));
    }
    throw Exception('Update failed: ${res.statusCode} ${res.body}');
  }


  Future<SignOff> submit(int id, SignOff body, String role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signoffs/$id/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...body.toJson(), 'role': role}),
    );
    if (res.statusCode == 200) {
      return SignOff.fromJson(jsonDecode(res.body));
    }
    throw Exception('Submit failed: ${res.statusCode} ${res.body}');
  }



  Future<void> remove(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/signoffs/$id'));
    if (res.statusCode != 204) throw Exception('Delete failed');
  }

  // get draft record for driver
  // GET current draft for this driver (backend should read driver from auth or query)
  Future<SignOff?> getDraftForDriver() async {
    final box = GetStorage();
    final driverId = box.read('driverId') ?? '';
    final res = await http.get(Uri.parse('$baseUrl/signoffs/draft/driver?driverId=$driverId'));
    if (res.statusCode == 200) {
      return SignOff.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 404) return null;
    throw Exception("getDraftForDriver failed: ${res.statusCode} ${res.body}");
  }

  Future<SignOff> createDraftForDriver(SignOff? payload) async {
    final map = payload?.toJson() ?? <String, dynamic>{};
    map['isSubmitted'] = false;

    final res = await http.post(
      Uri.parse('$baseUrl/signoffs/draft/driver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(map), // <-- never empty now
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return SignOff.fromJson(jsonDecode(res.body));
    }
    throw Exception("createDraftForDriver failed: ${res.statusCode} ${res.body}");
  }



}