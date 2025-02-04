import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/consolidated_form_submission_model.dart';

class FormRepository {
  static const String apiUrl = "https://your-api-url.com/submitForm"; // Replace with actual API endpoint

  Future<bool> submitForm(FormSubmissionModel formData) async {
    try {
      // Convert formData to JSON
      var jsonData = formData.toJson();
      print("Submitting Form Data: ${json.encode(jsonData)}"); // Debugging log

      // Send POST request to the API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(jsonData),
      );

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
