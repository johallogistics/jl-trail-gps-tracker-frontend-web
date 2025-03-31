import 'dart:convert';

import 'package:get/get.dart';
import '../../models/admin/driver_model.dart';
import '../../repositories/admin/driver_repository.dart';
import 'package:http/http.dart' as http;

class DriverController extends GetxController {


  var drivers = <Driver>[].obs;
  var selectedDriver = Rxn<Driver>();
  var service = DriverRepository();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDrivers();
  }

  /// ✅ Add Driver to Backend
  Future<void> addDriver(Driver driver) async {
    isLoading(true);

    final response = await service.addDriver(driver.toJson());
    fetchDrivers(); // Refresh list after adding
    if (response['success']) {
      Get.back();
      Get.snackbar('Success', response['message']);
    } else {
      Get.snackbar('Error', response['message']);
    }

    isLoading(false);
  }

  Future<void> fetchDrivers() async {
    try {
      final response = await DriverRepository.fetchDrivers();  // Full JSON response

      if (response['success'] == true) {
        var driverResponse = DriversResponse.fromJson(response);
        drivers.assignAll(driverResponse.drivers);
      } else {
        print('Failed to load drivers');
      }
    } catch (e) {
      print("Error fetching drivers: $e");
    }
  }

  /// Update Driver
  Future<void> updateDriver(String id, Driver updatedDriver) async {
    try {
      isLoading(true);
      bool success = await service.updateDriver(id, updatedDriver);

      if (success) {
        int index = drivers.indexWhere((driver) => driver.id == id);
        if (index != -1) {
          drivers[index] = updatedDriver; // Update list locally
        }
        selectedDriver.value = updatedDriver;
        Get.snackbar("Success", "Driver updated successfully!");
      } else {
        errorMessage.value = "Failed to update driver.";
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessage.value = 'Error updating driver.';
    } finally {
      isLoading(false);
    }
  }

  /// Delete Driver
  Future<void> deleteDriver(String id) async {
    try {
      isLoading(true);
      bool success = await service.deleteDriver(id);

      if (success) {
        drivers.removeWhere((driver) => driver.id == id);
        selectedDriver.value = drivers.isNotEmpty ? drivers.first : null;
        Get.snackbar("Deleted", "Driver deleted successfully!");
      } else {
        errorMessage.value = "Failed to delete driver.";
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessage.value = 'Error deleting driver.';
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> toggleLocation(String phone, bool isEnabled) async {
    try {
      final response = await http.put(
        Uri.parse("https://jl-trail-gps-tracker-backend-production.up.railway.app/drivers/phone/$phone/location"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'locationEnabled': isEnabled}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update location service'
        };
      }
    } catch (e) {
      print("Error toggling location: $e");
      return {
        'success': false,
        'message': 'Error occurred'
      };
    }
  }
}
