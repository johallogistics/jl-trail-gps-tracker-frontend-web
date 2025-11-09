import 'dart:convert';
import 'package:get/get.dart';
import '../../models/admin/driver_model.dart';
import '../../repositories/admin/driver_repository.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../utils/image_upload_service.dart'; // <— wherever you put the file above
// or import the functions directly if in the same file

class DriverController extends GetxController {
  var drivers = <Driver>[].obs;
  var selectedDriver = Rxn<Driver>();
  var service = DriverRepository();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // 👇 Manage a draftId for this "create driver" session
  final RxString draftId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDrivers();
  }

  /// Start a new driver creation flow: generate a fresh draftId
  void startNewDriverFlow() {
    draftId.value = const Uuid().v4();
  }

  /// Upload one or more documents for the pending driver (before driver exists)
  /// Optionally pass document types to label each file (AADHAAR, DL, PHOTO…)
  Future<List<String>> uploadDriverDocs({
    String folder = 'drivers',
    List<String>? documentTypes,
  }) async {
    if (draftId.value.isEmpty) startNewDriverFlow();
    final urls = await uploadMultipleViaProxy(
      draftId: draftId.value,
      folder: folder,
      documentTypes: documentTypes,
    );
    return urls;
  }

  /// ✅ Create Driver and claim all previously uploaded docs by draftId
  Future<void> addDriver(Driver driver) async {
    if (draftId.value.isEmpty) {
      // if user somehow skipped uploads, still generate one so BE is consistent
      startNewDriverFlow();
    }

    isLoading(true);

    // inject draftId into payload so backend can update documents.driverId
    final payload = driver.toJson();
    payload['draftId'] = draftId.value;

    final response = await service.addDriver(payload);
    await fetchDrivers(); // Refresh list after adding

    if (response['success'] == true) {
      Get.back();
      Get.snackbar('Success', response['message'] ?? 'Driver created');
      // reset draftId after success (new flow will get a fresh one)
      draftId.value = '';
    } else {
      Get.snackbar('Error', response['message'] ?? 'Failed to create driver');
    }

    isLoading(false);
  }

  Future<void> fetchDrivers() async {
    try {
      final response = await DriverRepository.fetchDrivers();
      if (response['success'] == true) {
        var driverResponse = DriversResponse.fromJson(response);
        drivers
          ..clear()
          ..assignAll(driverResponse.drivers);
      } else {
        print('Failed to load drivers');
      }
    } catch (e) {
      print("Error fetching drivers: $e");
    }
  }

  Future<void> updateDriver(String id, Driver updatedDriver) async {
    try {
      isLoading(true);
      final success = await service.updateDriver(id, updatedDriver);

      if (success) {
        final index = drivers.indexWhere((d) => d.id == id);
        if (index != -1) drivers[index] = updatedDriver;
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

  Future<void> deleteDriver(String id) async {
    try {
      isLoading(true);
      final success = await service.deleteDriver(id);

      if (success) {
        drivers.removeWhere((d) => d.id == id);
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
        return {'success': false, 'message': 'Failed to update location service'};
      }
    } catch (e) {
      print("Error toggling location: $e");
      return {'success': false, 'message': 'Error occurred'};
    }
  }
}
