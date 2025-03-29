import 'dart:convert';

class DriversResponse {
  final bool success;
  final String message;
  final Payload payload;

  DriversResponse({
    required this.success,
    required this.message,
    required this.payload,
  });

  factory DriversResponse.fromJson(Map<String, dynamic> json) {
    return DriversResponse(
      success: json['success'],
      message: json['message'],
      payload: Payload.fromJson(json['payload']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'payload': payload.toJson(),
    };
  }
}

class Payload {
  final List<Driver> drivers;

  Payload({required this.drivers});

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      drivers: List<Driver>.from(json['drivers'].map((x) => Driver.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drivers': drivers.map((x) => x.toJson()).toList(),
    };
  }
}

class Driver {
  final String? id;
  final String name;
  final String phone;   // Change the type to String to avoid errors
  final String employeeId;
  final String address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Driver({
    this.id,
    required this.name,
    required this.phone,
    required this.employeeId,
    required this.address,
    this.createdAt,
    this.updatedAt,
  });

  /// ✅ fromJson method with type casting
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'].toString(),  // Convert to String
      employeeId: json['employeeId'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'employeeId': employeeId,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Override `toString()` to print details
  @override
  String toString() {
    return "Driver(id: $id, name: $name, phone: $phone, employeeId: $employeeId, address: $address)";
  }
}


// Example usage:

