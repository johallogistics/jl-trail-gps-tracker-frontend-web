import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/consolidated_form_submission_model.dart';

class FormRepository {
  static const String apiUrl = "https://your-api-url.com/submitForm"; // Replace with actual API endpoint

  Future<bool> submitForm(FormSubmissionModel formData) async {
    try {
      // Convert formData to JSON
      var jsonData = formData.toJson();

      // Send POST request to the API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(jsonData),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("Error in API call: $e");
      return false;
    }
  }
}
