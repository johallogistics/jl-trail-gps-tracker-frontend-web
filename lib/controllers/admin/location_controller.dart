import 'package:get/get.dart';
import '../../models/admin/locations_model.dart';
import '../../repositories/admin/location_service_repository.dart';

class LocationController extends GetxController {
  // ✅ List of driver locations
  var locations = <Location>[].obs;

  // ✅ Track selected driver location
  var selectedLocation = Rxn<Location>();

  // ✅ Loading and error states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  /// ✅ Fetch locations with improved error handling
  Future<void> fetchLocations() async {
    try {
      isLoading(true);
      errorMessage.value = '';

      var service = LocationService();
      var result = await service.fetchLocations();

      if (result.isNotEmpty) {
        locations.assignAll(result);

        // ✅ Automatically select the first driver by default
        selectedLocation.value = result.first;
      } else {
        errorMessage.value = 'No drivers found.';
      }
    } catch (e) {
      print("Error: $e");
      errorMessage.value = 'Failed to load locations.';
    } finally {
      isLoading(false);
    }
  }

  /// ✅ Select a driver and update the selectedLocation
  void selectDriver(Location location) {
    selectedLocation.value = location;
  }
}
