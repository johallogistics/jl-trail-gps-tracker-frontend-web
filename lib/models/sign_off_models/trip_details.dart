import 'package:flutter/material.dart';
class TripControllers {
  TextEditingController tripRoute;
  TextEditingController startDate;
  TextEditingController endDate;
  TextEditingController startKm;
  TextEditingController endKm;
  TextEditingController tripKm;
  TextEditingController maxSpeed;
  TextEditingController weightGVW;
  TextEditingController actualDiesel;
  TextEditingController totalTripKm;
  TextEditingController actualFE;

  TripControllers({
    required this.tripRoute,
    required this.startDate,
    required this.endDate,
    required this.startKm,
    required this.endKm,
    required this.tripKm,
    required this.maxSpeed,
    required this.weightGVW,
    required this.actualDiesel,
    required this.totalTripKm,
    required this.actualFE,
  });

  factory TripControllers.fromTripDetail(TripDetail td) => TripControllers(
    tripRoute: TextEditingController(text: td.tripRoute),
    startDate: TextEditingController(text: td.tripStartDate),
    endDate: TextEditingController(text: td.tripEndDate),
    startKm: TextEditingController(text: td.startKm?.toString()),
    endKm: TextEditingController(text: td.endKm?.toString()),
    tripKm: TextEditingController(text: td.tripKm?.toString()),
    maxSpeed: TextEditingController(text: td.maxSpeed?.toString()),
    weightGVW: TextEditingController(text: td.weightGVW?.toString()),
    actualDiesel: TextEditingController(text: td.actualDieselLtrs?.toString()),
    totalTripKm: TextEditingController(text: td.totalTripKm?.toString()),
    actualFE: TextEditingController(text: td.actualFE?.toString()),
  );

  void dispose() {
    tripRoute.dispose();
    startDate.dispose();
    endDate.dispose();
    startKm.dispose();
    endKm.dispose();
    tripKm.dispose();
    maxSpeed.dispose();
    weightGVW.dispose();
    actualDiesel.dispose();
    totalTripKm.dispose();
    actualFE.dispose();
  }
}

class TripDetail {
  int? id;
  int? signOffId;
  int tripNo;
  String? tripRoute;
  String? tripStartDate; // ISO string
  String? tripEndDate;   // ISO string
  double? startKm;
  double? endKm;
  double? tripKm;
  double? maxSpeed;
  double? weightGVW;
  double? actualDieselLtrs;
  double? totalTripKm;
  double? actualFE;

  // Optional controllers if needed in UI
  TripControllers? controllers;

  TripDetail({
    this.id,
    this.signOffId,
    required this.tripNo,
    this.tripRoute,
    this.tripStartDate,
    this.tripEndDate,
    this.startKm,
    this.endKm,
    this.tripKm,
    this.maxSpeed,
    this.weightGVW,
    this.actualDieselLtrs,
    this.totalTripKm,
    this.actualFE,
    this.controllers,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'signOffId': signOffId,
    'tripNo': tripNo,
    'tripRoute': tripRoute,
    'tripStartDate': tripStartDate,
    'tripEndDate': tripEndDate,
    'startKm': startKm,
    'endKm': endKm,
    'tripKm': tripKm,
    'maxSpeed': maxSpeed,
    'weightGVW': weightGVW,
    'actualDieselLtrs': actualDieselLtrs,
    'totalTripKm': totalTripKm,
    'actualFE': actualFE,
  };

  // Create object from JSON
  factory TripDetail.fromJson(Map<String, dynamic> json) => TripDetail(
    id: json['id'],
    signOffId: json['signOffId'],
    tripNo: json['tripNo'] ?? 0,
    tripRoute: json['tripRoute'],
    tripStartDate: json['tripStartDate'],
    tripEndDate: json['tripEndDate'],
    startKm: (json['startKm'] as num?)?.toDouble(),
    endKm: (json['endKm'] as num?)?.toDouble(),
    tripKm: (json['tripKm'] as num?)?.toDouble(),
    maxSpeed: (json['maxSpeed'] as num?)?.toDouble(),
    weightGVW: (json['weightGVW'] as num?)?.toDouble(),
    actualDieselLtrs: (json['actualDieselLtrs'] as num?)?.toDouble(),
    totalTripKm: (json['totalTripKm'] as num?)?.toDouble(),
    actualFE: (json['actualFE'] as num?)?.toDouble(),
  );
}

