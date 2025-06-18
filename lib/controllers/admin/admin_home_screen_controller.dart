import 'dart:convert';
import 'package:get/get.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import '../../models/admin/driver_model.dart';
import '../../models/trials_model.dart';
import '../../repositories/consolidated_form_repository.dart';
import 'package:http/http.dart' as http;


class AdminController extends GetxController {
  var driversResponse = DriversResponse(
      success: false, drivers: []).obs;
  var selectedDriverLocation = Rx<LatLng?>(null);
  var selectedDriverId = ''.obs;

  // void fetchDriverLocation(String driverId) {
  //   selectedDriverId.value = driverId;
  //
  //   final driver = driversResponse.value.payload.drivers
  //       .firstWhere((d) => d.id == driverId);
  //   selectedDriverLocation.value = LatLng(driver.latitude, driver.longitude);
  // }

  setDriverLocation(double latitude, double longitude) {
    selectedDriverLocation.value = LatLng(latitude, longitude);
    selectedDriverLocation.refresh();
  }

  String driverResponse = '''
  {
    "success": true,
    "message": "Drivers fetched successfully",
    "payload": {
      "drivers": [
          {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "John Doe",
    "phone": 9876543210,
    "employeeId": "EMP12345",
    "address": "123 Main Street, Chennai, India",
    "latitude": 13.0827,
    "longitude": 80.2707,
    "createdAt": "2025-03-02T10:15:30Z",
    "updatedAt": "2025-03-02T12:45:00Z"
  },
  {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "name": "Jane Smith",
    "phone": 9876543222,
    "employeeId": "EMP12346",
    "address": "456 Elm Street, Chennai, India",
    "latitude": 28.7041,
    "longitude": 77.1025,
    "createdAt": "2025-03-02T11:00:00Z",
    "updatedAt": "2025-03-02T13:30:00Z"
  }
      ]
    }
  }
  ''';

  @override
  void onInit() {
    super.onInit();
    fetchTrails();
  }

  // void fetchDrivers() {
  //   var decodedData = json.decode(driverResponse);
  //   driversResponse.value = DriversResponse.fromJson(decodedData);
  // }

  void deleteDriver(String id) {
    driversResponse.update((val) {
      val?.drivers.removeWhere((driver) => driver.id == id);
    });
  }

  void editDriver(String id) {
    print("Edit Driver: $id");
    // Add edit functionality here
  }

  String trailsData = '''{
  "success": true,
  "message": "Drivers fetched successfully",
  "payload": {
    "trails": [
      {
        "id": "1",
        "vehicleRegNo": "TN01AB1234",
        "vehicleModel": "Model X",
        "brand": "Tesla",
        "startOdo": "12000",
        "endOdo": "12500",
        "startPlace": "Chennai",
        "endPlace": "Bangalore",
        "fuelConsumed": "50",
        "tripStartDate": "2025-03-01",
        "tripFinishDate": "2025-03-02",
        "location": "Chennai Warehouse",
        "date": "2025-03-01",
        "masterDriverName": "Rajesh Kumar",
        "empCode": "EMP1001",
        "mobileNo": "9876543210",
        "customerDriverName": "Arun Sharma",
        "customerMobileNo": "9876501234"
      },
      {
        "id": "2",
        "vehicleRegNo": "KA05CD5678",
        "vehicleModel": "Swift Dzire",
        "brand": "Maruti Suzuki",
        "startOdo": "50000",
        "endOdo": "50550",
        "startPlace": "Bangalore",
        "endPlace": "Hyderabad",
        "fuelConsumed": "35",
        "tripStartDate": "2025-03-03",
        "tripFinishDate": "2025-03-04",
        "location": "Bangalore Depot",
        "date": "2025-03-03",
        "masterDriverName": "Vinay Reddy",
        "empCode": "EMP2002",
        "mobileNo": "9876543222",
        "customerDriverName": "Sandeep Verma",
        "customerMobileNo": "9876505678"
      }
    ]
  }
}''';



  Rx<TrailResponse> trailsResponse = TrailResponse(message: "", payload: TrailPayload(trails: [])).obs;
  var selectedTrailId = ''.obs;

  var selectedTrail = Rxn<Trail>(); // Stores the selected trail
  var isEditing = false.obs; // Toggle editing mode

  void setTrails(List<Trail> trails) {
    trailsResponse.value = TrailResponse(
      message: "Trails updated",
      payload: TrailPayload(trails: trails),
    );
  }

  void viewTrail(Trail trail) {
    selectedTrail.value = trail;
    isEditing.value = false;
  }

  void enableEditing() {
    isEditing.value = true;
  }

  void saveChanges() {
    isEditing.value = false;
    Get.back(); // Close popup after saving
  }

  // Fetch API Data using service

  var isLoading = false.obs;

  Future<bool> createTrail(TrailRequest trailRequest) async {
    try {
      isLoading.value = true;
      final success = await FormRepository.createTrail(trailRequest);
      if (success) {
        fetchTrails(); // Optional: Refresh list after creation
      }
      return success;
    } finally {
      isLoading.value = false;
    }
  }

  void fetchTrails() async {
    try {
      isLoading.value = true;

      final response = await FormRepository.fetchTrails(); // ✅ call service layer
      if (response != null) {
        trailsResponse.value = response;
        print('✅ Trails fetched successfully');
      } else {
        print('❌ Failed to fetch trails from service');
      }
    } catch (e) {
      print('❌ Error in TrailsController: $e');
    } finally {
      isLoading.value = false;
    }
  }


  static const String baseUrl = "https://jl-trail-gps-tracker-backend-production.up.railway.app";

  void deleteTrail(String id) async {
    final url = Uri.parse("$baseUrl/form-submissions/$id");

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Remove from local state if delete was successful
        trailsResponse.update((val) {
          val?.payload.trails.removeWhere((trail) => trail.id == id);
        });
        Get.snackbar('Deleted', 'Trail deleted successfully');
        fetchTrails();
      } else {
        Get.snackbar('Error', 'Failed to delete trail: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting trail: $e');
      Get.snackbar('Error', 'An error occurred while deleting trail');
    }
  }

  void editTrail(String id) {
    print("Edit Trail: $id");
    // Add edit functionality here
  }
}
