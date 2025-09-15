// lib/models/sign_off.dart
import 'package:flutter/material.dart';
import 'package:trail_tracker/models/sign_off_models/participant.dart';
import 'package:trail_tracker/models/sign_off_models/photo.dart';
import 'package:trail_tracker/models/sign_off_models/trip_details.dart';

class CustomerVehicleDetails {
  String? tripDuration;
  String? vehicleNo;
  String? saleDate; // ISO
  String? model;
  String? application;
  String? customerVerbatim;
  String? tripRoute;
  String? roadType;
  String? vehicleCheckDate; // ISO
  String? issuesFoundOnVehicleCheck;

  // Make controllers nullable (lazy)
  TextEditingController? vehicleCheckDateController;
  TextEditingController? saleDateController;

  CustomerVehicleDetails({
    this.vehicleCheckDate,
    this.saleDate,
  }) {
    // do NOT create controllers eagerly; keep them null for lazy init
  }

  Map<String, dynamic> toJson() => {
    'tripDuration': tripDuration,
    'vehicleNo': vehicleNo,
    'saleDate': saleDate,
    'model': model,
    'application': application,
    'customerVerbatim': customerVerbatim,
    'tripRoute': tripRoute,
    'roadType': roadType,
    'vehicleCheckDate': vehicleCheckDate,
    'issuesFoundOnVehicleCheck': issuesFoundOnVehicleCheck,
  };

  static CustomerVehicleDetails fromJson(Map<String, dynamic>? j) {
    if (j == null) return CustomerVehicleDetails();
    return CustomerVehicleDetails(
      vehicleCheckDate: j['vehicleCheckDate'] as String?,
      saleDate: j['saleDate'] as String?,
    )
      ..tripDuration = j['tripDuration'] as String?
      ..vehicleNo = j['vehicleNo'] as String?
      ..model = j['model'] as String?
      ..application = j['application'] as String?
      ..customerVerbatim = j['customerVerbatim'] as String?
      ..tripRoute = j['tripRoute'] as String?
      ..roadType = j['roadType'] as String?
      ..issuesFoundOnVehicleCheck = j['issuesFoundOnVehicleCheck'] as String?;
  }

  void copyFrom(CustomerVehicleDetails? other) {
    if (other == null) return;
    tripDuration = other.tripDuration;
    vehicleNo = other.vehicleNo;
    saleDate = other.saleDate;
    model = other.model;
    application = other.application;
    customerVerbatim = other.customerVerbatim;
    tripRoute = other.tripRoute;
    roadType = other.roadType;
    vehicleCheckDate = other.vehicleCheckDate;
    issuesFoundOnVehicleCheck = other.issuesFoundOnVehicleCheck;

    // If controllers exist, update text; otherwise leave null for lazy init
    if (vehicleCheckDateController != null) vehicleCheckDateController!.text = vehicleCheckDate ?? '';
    if (saleDateController != null) saleDateController!.text = saleDate ?? '';
  }
}


class SignOff {
  int? id;
  String? customerName;
  double? customerExpectedFE;
  double? beforeTrialsFE;
  double? afterTrialsFE;
  CustomerVehicleDetails? customerVehicleDetails;
  String? issuesFoundDuringTrial;
  String? trialRemarks;
  String? customerRemarks;

  String driverId;
  String createdByRole;

  List<TripDetail> tripDetails;
  List<ParticipantSignOff> participants;
  List<Photo> photos;
  bool? isSubmitted;

  SignOff({
    this.id,
    this.customerName,
    this.customerExpectedFE,
    this.beforeTrialsFE,
    this.afterTrialsFE,
    this.customerVehicleDetails,
    this.issuesFoundDuringTrial,
    this.trialRemarks,
    this.customerRemarks,
    required this.driverId,
    required this.createdByRole,
    this.tripDetails = const [],
    this.participants = const [],
    this.photos = const [],
    this.isSubmitted,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'customerExpectedFE': customerExpectedFE,
    'beforeTrialsFE': beforeTrialsFE,
    'afterTrialsFE': afterTrialsFE,
    'customerVehicleDetails': customerVehicleDetails?.toJson(),
    'issuesFoundDuringTrial': issuesFoundDuringTrial,
    'trialRemarks': trialRemarks,
    'customerRemarks': customerRemarks,
    'driverId': driverId,
    'createdByRole': createdByRole,
    'tripDetails': tripDetails.map((e) => e.toJson()).toList(),
    'participants': participants.map((e) => e.toJson()).toList(),
    'photos': photos.map((e) => e.toJson()).toList(),
    'isSubmitted': isSubmitted,
  };

  factory SignOff.fromJson(Map<String, dynamic> j) => SignOff(
    id: j['id'] as int?,
    customerName: j['customerName'] as String?,
    customerExpectedFE: (j['customerExpectedFE'] as num?)?.toDouble(),
    beforeTrialsFE: (j['beforeTrialsFE'] as num?)?.toDouble(),
    afterTrialsFE: (j['afterTrialsFE'] as num?)?.toDouble(),
    customerVehicleDetails:
    CustomerVehicleDetails.fromJson(j['customerVehicleDetails'] as Map<String, dynamic>?),
    issuesFoundDuringTrial: j['issuesFoundDuringTrial'] as String?,
    trialRemarks: j['trialRemarks'] as String?,
    customerRemarks: j['customerRemarks'] as String?,
    driverId: j['driverId'] as String? ?? '',
    createdByRole: j['createdByRole'] as String? ?? '',
    tripDetails: (j['tripDetails'] as List<dynamic>? ?? [])
        .map((e) => TripDetail.fromJson(e as Map<String, dynamic>))
        .toList(),
    participants: (j['participants'] as List<dynamic>? ?? [])
        .map((e) => ParticipantSignOff.fromJson(e as Map<String, dynamic>))
        .toList(),
    photos: (j['photos'] as List<dynamic>? ?? [])
        .map((e) => Photo.fromJson(e as Map<String, dynamic>))
        .toList(),
    isSubmitted: j['isSubmitted'] as bool?,
  );
}
