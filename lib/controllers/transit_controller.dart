import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransitController extends GetxController {
  final storage = GetStorage();

  var currentTransitId = Rxn<int>();

  Future<void> startTransit({
    required double startLat,
    required double startLng,
    required String startAddress,
    required double endLat,
    required double endLng,
    required String endAddress,
    String? notes,
  }) async {
    try {
      final driverId = storage.read("driverId");
      if (driverId == null) {
        Get.snackbar("Error", "Driver not logged in");
        return;
      }

      final response = await http.post(
        Uri.parse("http://localhost:3000/transits"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driverId": driverId,
          "startLat": startLat,
          "startLng": startLng,
          "startAddress": startAddress,
          "endLat": endLat,
          "endLng": endLng,
          "endAddress": endAddress,
          "notes": notes ?? "",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        currentTransitId.value = data["id"];
        Get.snackbar("Success", "Transit started");
      } else {
        Get.snackbar("Error", response.body);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> endTransit(int transitId) async {
    try {
      final response = await http.put(
        Uri.parse("http://localhost:3000/transits/$transitId/end"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        currentTransitId.value = null;
        Get.snackbar("Success", "Transit ended");
      } else {
        Get.snackbar("Error", response.body);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
