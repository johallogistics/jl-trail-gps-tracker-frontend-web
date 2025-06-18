import 'dart:convert';
import '../api/api_manager.dart';
import '../models/consolidated_form_submission_model.dart';
import '../models/trials_model.dart';
import 'package:http/http.dart' as http;

class FormRepository {
  static const String apiUrl = "form-submissions"; // API endpoint is relative to base URL

  Future<bool> submitForm(FormSubmissionModel formData) async {
    try {
      // Convert formData to JSON
      var jsonData = formData.toJson();
      print("Submitting Form Data: ${json.encode(jsonData)}"); // Debugging log

      // Send POST request to the API using ApiManager
      final response = await ApiManager.post(apiUrl, jsonData);

      // Check API response
      if (response.statusCode == 200) {
        print("Form submitted successfully!");
        return true;
      } else {
        print("Failed to submit form. Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error during API call: $e");
      return false;
    }
  }


  static const String baseUrl = "https://jl-trail-gps-tracker-backend-production.up.railway.app";

  static Future<TrailResponse?> fetchTrails() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/form-submissions'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final trailResponse = TrailResponse.fromJson(jsonData);
        return trailResponse;
      } else {
        print('❌ Failed to load trails. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching trails: $e');
      return null;
    }
  }
  static const String _baseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app/form-submissions';

  // ✅ POST Trail (Create new trail)
  static Future<bool> createTrail(TrailRequest trailRequest) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(trailRequest.toMap()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Trail created successfully');
        return true;
      } else {
        print('❌ Failed to create trail. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating trail: $e');
      return false;
    }
  }

}
