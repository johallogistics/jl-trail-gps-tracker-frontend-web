import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_manager.dart';
import '../models/shift_log_model.dart';
import '../utils/translate_services.dart';

class ShiftLogRepository {
  Future<List<ShiftLog>> fetchShiftLogs() async {
    final response = await ApiManager.get('shiftlogs');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ShiftLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shift logs');
    }
  }

  Future<bool> postShiftLog(ShiftLog shiftLog) async {
    final response = await ApiManager.post('shiftlogs', shiftLog.toJson());
    return response.statusCode == 201;
  }


  Future<ShiftLogResponse?> fetchShiftLogById(String id) async {
    final response = await ApiManager.get('shifts/1');
    if (response.statusCode == 200) {
      String targetLanguage = "ta"; // Tamil
      Map<String, dynamic> json =  jsonDecode(response.body);
      print("Translated JSON::: $json");
      Map<String, dynamic> translatedJson = await translateJson(json, targetLanguage);
      print("Translated JSON::: $translatedJson");
      return ShiftLogResponse.fromJson(translatedJson);
    } else {
      return null;
    }
  }
}
