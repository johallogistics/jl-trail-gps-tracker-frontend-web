import 'dart:convert';
import 'package:get/get.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import '../../models/admin/driver_model.dart';

class AdminController extends GetxController {
  var driversResponse = DriversResponse(success: false, message: "", payload: Payload(drivers: [])).obs;
  var selectedDriverLocation = Rx<LatLng?>(null);
  var selectedDriverId = ''.obs;

  void fetchDriverLocation(String driverId) {
    selectedDriverId.value = driverId;

    final driver = driversResponse.value.payload.drivers.firstWhere((d) => d.id == driverId);
    selectedDriverLocation.value = LatLng(driver.latitude, driver.longitude);
  }


  String response = '''
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
    fetchDrivers();
  }

  void fetchDrivers() {
    var decodedData = json.decode(response);
    driversResponse.value = DriversResponse.fromJson(decodedData);
  }

  void deleteDriver(String id) {
    driversResponse.update((val) {
      val?.payload.drivers.removeWhere((driver) => driver.id == id);
    });
  }

  void editDriver(String id) {
    print("Edit Driver: $id");
    // Add edit functionality here
  }
}
