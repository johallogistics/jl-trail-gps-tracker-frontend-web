// lib/models/sign_off.dart

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

  static CustomerVehicleDetails fromJson(Map<String, dynamic> j) => CustomerVehicleDetails()
    ..tripDuration = j['tripDuration']
    ..vehicleNo = j['vehicleNo']
    ..saleDate = j['saleDate']
    ..model = j['model']
    ..application = j['application']
    ..customerVerbatim = j['customerVerbatim']
    ..tripRoute = j['tripRoute']
    ..roadType = j['roadType']
    ..vehicleCheckDate = j['vehicleCheckDate']
    ..issuesFoundOnVehicleCheck = j['issuesFoundOnVehicleCheck'];
}

class SignOff {
  int? id;
  String customerName;
  double? customerExpectedFE;
  double? beforeTrialsFE;
  double? afterTrialsFE;
  CustomerVehicleDetails? customerVehicleDetails;
  String? issuesFoundDuringTrial;
  String? trialRemarks;
  String? customerRemarks;
  String createdByRole; // 'DRIVER' | 'ADMIN'
  List<TripDetail> tripDetails;
  List<ParticipantSignOff> participants;
  List<Photo> photos;

  SignOff({
    this.id,
    required this.customerName,
    this.customerExpectedFE,
    this.beforeTrialsFE,
    this.afterTrialsFE,
    this.customerVehicleDetails,
    this.issuesFoundDuringTrial,
    this.trialRemarks,
    this.customerRemarks,
    required this.createdByRole,
    this.tripDetails = const [],
    this.participants = const [],
    this.photos = const [],
  });

  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'customerExpectedFE': customerExpectedFE,
    'beforeTrialsFE': beforeTrialsFE,
    'afterTrialsFE': afterTrialsFE,
    'customerVehicleDetails': customerVehicleDetails?.toJson(),
    'issuesFoundDuringTrial': issuesFoundDuringTrial,
    'trialRemarks': trialRemarks,
    'customerRemarks': customerRemarks,
    'createdByRole': createdByRole,
    'tripDetails': tripDetails.map((e) => e.toJson()).toList(),
    'participants': participants.map((e) => e.toJson()).toList(),
    'photos': photos.map((e) => e.toJson()).toList(),
  };

  factory SignOff.fromJson(Map<String, dynamic> j) => SignOff(
    id: j['id'],
    customerName: j['customerName'],
    customerExpectedFE: (j['customerExpectedFE'] as num?)?.toDouble(),
    beforeTrialsFE: (j['beforeTrialsFE'] as num?)?.toDouble(),
    afterTrialsFE: (j['afterTrialsFE'] as num?)?.toDouble(),
    customerVehicleDetails: j['customerVehicleDetails'] != null ? CustomerVehicleDetails.fromJson(j['customerVehicleDetails']) : null,
    issuesFoundDuringTrial: j['issuesFoundDuringTrial'],
    trialRemarks: j['trialRemarks'],
    customerRemarks: j['customerRemarks'],
    createdByRole: j['createdByRole'],
    tripDetails: (j['tripDetails'] as List<dynamic>? ?? []).map((e) => TripDetail.fromJson(e)).toList(),
    participants: (j['participants'] as List<dynamic>? ?? [])
        .map((e) => ParticipantSignOff.fromJson(e))
        .toList(),    photos: (j['photos'] as List<dynamic>? ?? []).map((e) => Photo.fromJson(e)).toList(),
  );
}