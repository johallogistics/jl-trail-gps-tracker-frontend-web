import 'dart:convert';

class DriversResponse {
  final bool success;
  final List<Driver> drivers;

  DriversResponse({
    required this.success,
    required this.drivers,
  });

  factory DriversResponse.fromJson(Map<String, dynamic> json) {
    return DriversResponse(
      success: json['success'],
      // ✅ Fetch drivers from the `data` key, not `payload`
      drivers: List<Driver>.from(json['data'].map((x) => Driver.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'drivers': drivers.map((x) => x.toJson()).toList(),
    };
  }
}

class Driver {
  String? id;
  String name;
  String phone;
  String employeeId;
  String address;
  bool locationEnabled;

  Driver({
    this.id,
    required this.name,
    required this.phone,
    required this.employeeId,
    required this.address,
    required this.locationEnabled,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      employeeId: json['employeeId'] ?? "",
      address: json['address'] ?? "",
      locationEnabled: json['locationEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "employeeId": employeeId,
      "address": address,
      "locationEnabled": locationEnabled,
    };
  }
}
