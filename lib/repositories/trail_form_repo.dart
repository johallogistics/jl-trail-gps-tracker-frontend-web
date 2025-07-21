import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/trial_form_new_model.dart';

class TrialFormApiService {
  static const String baseUrl =
      'https://jl-trail-gps-tracker-backend-production.up.railway.app';
  // 🔹 Create TrialForm
  static Future<bool> submitForm(TrialForm form) async {
    final url = Uri.parse('$baseUrl/trialForms');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(form.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 🔹 Get All TrialForms
  static Future<List<TrialForm>> fetchTrialForms() async {
    final url = Uri.parse('$baseUrl/trialForms');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TrialForm.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load trial forms');
    }
  }

  // 🔹 Get Single TrialForm by ID
  static Future<TrialForm?> getTrialFormById(int id) async {
    final url = Uri.parse('$baseUrl/trialForms/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return TrialForm.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  // 🔹 Update TrialForm (Edit)
  static Future<bool> updateTrialForm(TrialForm form) async {
    if (form.id == null) return false;

    final url = Uri.parse('$baseUrl/trialForms/${form.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(form.toJson()),
    );
    return response.statusCode == 200;
  }

  // 🔹 Delete TrialForm
  static Future<bool> deleteTrialForm(int id) async {
    final url = Uri.parse('$baseUrl/trialForms/$id');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
