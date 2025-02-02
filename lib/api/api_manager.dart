import 'package:http/http.dart' as http;

class ApiManager {
  static const String baseUrl = 'http://localhost:3000';

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(url, body: body);
  }
}
