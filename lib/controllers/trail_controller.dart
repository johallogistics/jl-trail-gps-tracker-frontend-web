import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TrailController extends GetxController {
  // Assuming you have a way to get the current driver ID (e.g., from authentication)
  final String currentDriverId = 'driver123'; // Replace with actual driver ID

  // Observable RxBool to track active trail status
  var hasActiveTrail = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkActiveTrail();
  }

  Future<void> _checkActiveTrail() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/check-active-trail/$currentDriverId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        hasActiveTrail.value = data['hasActiveTrail'];
      } else {
        throw Exception('Failed to check active trail');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
