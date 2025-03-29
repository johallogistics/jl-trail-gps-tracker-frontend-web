import 'package:get/get.dart';
import '../../models/admin/locations_model.dart';
import '../../repositories/admin/driver_repository.dart';
import '../../repositories/admin/location_service_repository.dart';

class LocationController extends GetxController {
  // ✅ List of driver locations
  var locations = <Location>[].obs;

  // ✅ Track selected driver location
  var selectedLocation = Rxn<Location>();

  // ✅ Loading and error states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// ✅ Fetch driver location by phone
  Future<void> fetchDriverLocation(String phone) async {
    try {
      isLoading(true);
      errorMessage.value = '';

      var service = DriverRepository();
      var location = await service.fetchDriverLocation(phone);

      if (location != null) {
        selectedLocation.value = location as Location?;
      } else {
        errorMessage.value = 'No location found.';
      }
    } catch (e) {
      print("❌ Error: $e");
      errorMessage.value = 'Failed to load location.';
    } finally {
      isLoading(false);
    }
  }
}
