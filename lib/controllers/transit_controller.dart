import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransitController extends GetxController {
  final String baseUrl = "https://jl-trail-gps-tracker-backend-production.up.railway.app";
  final storage = GetStorage();

  // Holds the current ongoing transit ID
  var currentTransitId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    // Load ongoing transit ID if saved
    currentTransitId.value = storage.read("currentTransitId");
  }

  /// Start a new transit
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
      final driverId = storage.read<String>("driverId");
      if (driverId == null) {
        Get.snackbar("Error", "Driver not logged in");
        return;
      }

      // Prevent starting new transit if an ongoing one exists
      if (currentTransitId.value != null) {
        Get.snackbar("Info", "You have an ongoing transit. Complete it first.");
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/transits"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "driverId": driverId,
          "startLatitude": startLat,
          "startLongitude": startLng,
          "startAddress": startAddress,
          "endLatitude": endLat,
          "endLongitude": endLng,
          "endAddress": endAddress,
          "notes": notes ?? "",
          "status": "ONGOING",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        currentTransitId.value = data["id"];
        // Save to local storage so it persists
        storage.write("currentTransitId", currentTransitId.value);
        Get.snackbar("Success", "Transit started");
      } else {
        Get.snackbar("Error", response.body);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Complete the ongoing transit
  Future<void> completeTransit() async {
    try {
      final transitId = currentTransitId.value;
      if (transitId == null) {
        Get.snackbar("Info", "No ongoing transit found");
        return;
      }

      final response = await http.put(
        Uri.parse("$baseUrl/transits/$transitId/complete"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        currentTransitId.value = null;
        storage.remove("currentTransitId");
        Get.snackbar("Success", "Transit completed");
      } else {
        Get.snackbar("Error", response.body);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<Map<String, dynamic>?> getOngoingTransit() async {
    try {
      final driverId = storage.read<String>("driverId");
      if (driverId == null) return null;

      final response = await http.get(
        Uri.parse("$baseUrl/transits/ongoing/$driverId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // returns the transit object
      } else if (response.statusCode == 404) {
        return null; // no ongoing transit
      } else {
        Get.snackbar("Error", response.body);
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    }
  }

}
