import 'dart:convert';
import 'package:intl/intl.dart';

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
  List<String> proofDocs = [];

  /// Store as DateTime for reliable comparisons
  DateTime? drivingLicenseExpiryDate;

  Driver({
    this.id,
    required this.name,
    required this.phone,
    required this.employeeId,
    required this.address,
    required this.locationEnabled,
    required this.proofDocs,
    this.drivingLicenseExpiryDate,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      employeeId: json['employeeId'] ?? "",
      address: json['address'] ?? "",
      locationEnabled: json['locationEnabled'] ?? false,
      proofDocs: (json['proofDocs'] as List<dynamic>?)
          ?.map((doc) => doc.toString())
          .toList() ??
          [],
      drivingLicenseExpiryDate: _parseExpiry(json['drivingLicenseExpiryDate']),
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
      "proofDocs": proofDocs,
      // Save as YYYY-MM-DD for backend sanity
      "drivingLicenseExpiryDate": drivingLicenseExpiryDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(drivingLicenseExpiryDate!.toUtc()),
    };
  }

  // ---------- Helpers for UI ----------
  /// Whole-day difference (today -> expiry). Negative means already expired.
  int? get licenseDaysLeft {
    if (drivingLicenseExpiryDate == null) return null;
    final today = DateTime.now();
    final justDate = DateTime(today.year, today.month, today.day);
    final exp = DateTime(
      drivingLicenseExpiryDate!.year,
      drivingLicenseExpiryDate!.month,
      drivingLicenseExpiryDate!.day,
    );
    return exp.difference(justDate).inDays;
  }

  bool get isLicenseExpired => (licenseDaysLeft ?? 1) < 0;

  /// “Soon” = due within 30 days (including today).
  bool get isLicenseExpiringSoon {
    final d = licenseDaysLeft;
    if (d == null) return false;
    return d >= 0 && d <= 30;
  }

  String? get formattedLicenseExpiry {
    if (drivingLicenseExpiryDate == null) return null;
    return DateFormat('dd MMM yyyy').format(drivingLicenseExpiryDate!);
  }
}

/// Accepts ISO strings like "2025-12-31" or full ISO with time.
/// (If you expect other formats, add more parsing as needed.)
DateTime? _parseExpiry(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  try {
    return DateTime.parse(s).toLocal();
  } catch (_) {
    // Add other formats here if your backend sends them (e.g., dd/MM/yyyy).
    return null;
  }
}
