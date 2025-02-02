import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> translateJson(Map<String, dynamic> jsonData, String targetLang) async {
  Future<dynamic> translateText(String text) async {
    final uri = Uri.parse("https://api.mymemory.translated.net/get?q=$text&langpair=en|$targetLang");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse["responseData"]["translatedText"];
    } else {
      return text; // Return original text if translation fails
    }
  }

  Future<Map<String, dynamic>> recursiveTranslate(Map<String, dynamic> data) async {
    Map<String, dynamic> translatedData = {};

    for (var key in data.keys) {
      if (data[key] is String) {
        translatedData[key] = await translateText(data[key]); // Translate string values
      } else if (data[key] is Map<String, dynamic>) {
        translatedData[key] = await recursiveTranslate(data[key]); // Recursively translate nested JSON
      } else {
        translatedData[key] = data[key]; // Keep other data types unchanged
      }
    }
    return translatedData;
  }

  return await recursiveTranslate(jsonData);
}
