import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/api_manager.dart';
import '../models/shift_log_model.dart';
import '../utils/translate_services.dart';


class ShiftLogRepository {

  final box = GetStorage();

  Future<List<ShiftLog>> fetchShiftLogs() async {
    final response = await ApiManager.get('shifts');
    if (response.statusCode == 200) {
      String targetLanguage = box.read('selectedLanguage') ?? 'en'; // Get selected language
      List<dynamic> data = jsonDecode(response.body);
      // Translate each item in the list
      List<Map<String, dynamic>> translatedData = await Future.wait(
          data.map((json) async => await translateJson(json, targetLanguage))
      );
      return translatedData.map((json) => ShiftLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shift logs');
    }
  }


  Future<bool> postShiftLog(ShiftLog shiftLog) async {
    final response = await ApiManager.post('shifts', shiftLog.toJson());
    return response.statusCode == 201;
  }


  Future<ShiftLogResponse?> fetchShiftLogById(String id) async {
    final response = await ApiManager.get('shifts/$id');
    if (response.statusCode == 200) {
      String targetLanguage = box.read('selectedLanguage') ?? 'en';
      Map<String, dynamic> json =  jsonDecode(response.body);
      Map<String, dynamic> translatedJson = await translateJson(json, targetLanguage);
      return ShiftLogResponse.fromJson(translatedJson);
    } else {
      return null;
    }
  }
}
