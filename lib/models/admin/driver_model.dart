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
  final String id;
  final String name;
  final int phone;
  final String employeeId;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.employeeId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      employeeId: json['employeeId'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
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
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Example usage:

