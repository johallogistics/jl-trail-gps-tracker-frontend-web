import 'dart:convert';
import '../api/api_manager.dart';
import '../models/consolidated_form_submission_model.dart';

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
}
