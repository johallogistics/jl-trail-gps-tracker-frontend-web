import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api/api_manager.dart';
import '../../models/shift_log_model.dart';


class ShiftLogRepository {

  final box = GetStorage();
  final String baseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app'; // Replace with your backend URL


  // Future<List<ShiftLog>> fetchShiftLogs() async {
  //   final response = await ApiManager.get('dailyReports');
  //   if (response.statusCode == 200) {
  //     String targetLanguage = box.read('selectedLanguage') ?? 'en'; // Get selected language
  //     List<dynamic> data = jsonDecode(response.body);
  //     // Translate each item in the list
  //     List<Map<String, dynamic>> translatedData = await Future.wait(
  //         data.map((json) async => await translateJson(json, targetLanguage))
  //     );
  //     return translatedData.map((json) => ShiftLog.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load shift logs');
  //   }
  // }

  Future<List<ShiftLog>> fetchShiftLogs() async {
    final response = await ApiManager.get('dailyReports');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['payload'];
      return data.map((json) => ShiftLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shift logs');
    }
  }



  Future<bool> postShiftLog(ShiftLog shiftLog) async {
    try {
      final response = await ApiManager.post('dailyReport', shiftLog.toJsonWithoutId());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in postShiftLog: $e');
      return false;
    }
  }



  Future<ShiftLogResponse?> fetchShiftLogById(String id) async {
    final response = await ApiManager.get('shifts/$id');
    if (response.statusCode == 200) {
      // String targetLanguage = box.read('selectedLanguage') ?? 'en';
      Map<String, dynamic> json =  jsonDecode(response.body);
      // Map<String, dynamic> translatedJson = await translateJson(json, targetLanguage);
      return ShiftLogResponse.fromJson(json);
    } else {
      return null;
    }
  }


  // Update Shift Log (PUT /dailyReports/:id)
  Future<bool> updateShiftLog(ShiftLog log) async {
    final url = Uri.parse('$baseUrl/dailyReports/${log.id}');
    final body = jsonEncode(log.toJson());

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  // Delete Shift Log (DELETE /dailyReports/:id)
  Future<bool> deleteShiftLog(int id) async {
    final url = Uri.parse('$baseUrl/dailyReports/$id');

    final response = await http.delete(
      url
    );

    return response.statusCode == 200;
  }
}
