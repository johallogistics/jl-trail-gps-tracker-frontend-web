import 'package:flutter/cupertino.dart';
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
    // Restore from persistent storage
    final savedId = storage.read<String>("currentTransitId");
    if (savedId != null) {
      currentTransitId.value = savedId;

      // Optional: double check with backend if still ongoing
      getOngoingTransit().then((transit) {
        if (transit == null) {
          // No active transit in backend, cleanup local storage
          currentTransitId.value = null;
          storage.remove("currentTransitId");
        } else {
          currentTransitId.value = transit["id"].toString();
        }
      });
    }
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
      // read without forcing a type, then convert to String
      final rawDriverId = storage.read('driverId');
      final driverId = rawDriverId?.toString();
      debugPrint('startTransit: rawDriverId=$rawDriverId, driverId=$driverId');

      if (driverId == null || driverId.isEmpty) {
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

        // Convert returned id to string to match your currentTransitId type
        final returnedId = data['id'];
        final returnedIdStr = returnedId?.toString();

        currentTransitId.value = returnedIdStr;
        // Save to local storage so it persists (store as String)
        storage.write("currentTransitId", returnedIdStr);

        debugPrint('startTransit: created transit id=$returnedIdStr');
        Get.snackbar("Success", "Transit started");
      } else {
        debugPrint('startTransit failed: ${response.statusCode} ${response.body}');
        Get.snackbar("Error", response.body);
      }
    } catch (e) {
      print("Error*********** $e");
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

      final response = await http.post(
        Uri.parse("$baseUrl/transits/$transitId/complete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        currentTransitId.value = null;
        storage.remove("currentTransitId");
        Get.snackbar("Success", "Transit completed");
      } else {
        Get.snackbar("Error::::", response.body);
      }
    } catch (e) {
      Get.snackbar("Error222", e.toString());
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
