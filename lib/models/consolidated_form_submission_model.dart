import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehicleDetail {
  TextEditingController vehicleRegNo;
  TextEditingController brand;
  TextEditingController chassisNo;
  TextEditingController vehicleModel;
  TextEditingController wheelBase;
  TextEditingController atsType;
  TextEditingController emission;
  TextEditingController tyreBrand;
  TextEditingController application;
  TextEditingController gvwCarried;
  TextEditingController tripStartDate;
  TextEditingController startOdo;
  TextEditingController tripFinishDate;
  TextEditingController endOdo;
  TextEditingController startPlace;
  TextEditingController endPlace;
  TextEditingController totalTrailKms;
  TextEditingController fuelConsumed;
  TextEditingController adBlueConsumedCluster;
  RxBool didRegenerationHappen;
  TextEditingController leadDistance;
  TextEditingController drivingSpeed;
  TextEditingController actualFeInBB;

  VehicleDetail({
    required this.vehicleRegNo,
    required this.brand,
    required this.chassisNo,
    required this.vehicleModel,
    required this.wheelBase,
    required this.atsType,
    required this.emission,
    required this.tyreBrand,
    required this.application,
    required this.gvwCarried,
    required this.tripStartDate,
    required this.startOdo,
    required this.tripFinishDate,
    required this.endOdo,
    required this.startPlace,
    required this.endPlace,
    required this.totalTrailKms,
    required this.fuelConsumed,
    required this.adBlueConsumedCluster,
    required this.didRegenerationHappen,
    required this.leadDistance,
    required this.drivingSpeed,
    required this.actualFeInBB,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    return VehicleDetail(
      vehicleRegNo: TextEditingController(text: json['vehicleRegNo'] ?? ""),
      brand: TextEditingController(text: json['brand'] ?? ""),
      chassisNo: TextEditingController(text: json['chassisNo'] ?? ""),
      vehicleModel: TextEditingController(text: json['vehicleModel'] ?? ""),
      wheelBase: TextEditingController(text: json['wheelBase'] ?? ""),
      atsType: TextEditingController(text: json['atsType'] ?? ""),
      emission: TextEditingController(text: json['emission'] ?? ""),
      tyreBrand: TextEditingController(text: json['tyreBrand'] ?? ""),
      application: TextEditingController(text: json['application'] ?? ""),
      gvwCarried: TextEditingController(text: json['gvwCarried'] ?? ""),
      tripStartDate: TextEditingController(text: json['tripStartDate'] ?? ""),
      startOdo: TextEditingController(text: json['startOdo'] ?? ""),
      tripFinishDate: TextEditingController(text: json['tripFinishDate'] ?? ""),
      endOdo: TextEditingController(text: json['endOdo'] ?? ""),
      startPlace: TextEditingController(text: json['startPlace'] ?? ""),
      endPlace: TextEditingController(text: json['endPlace'] ?? ""),
      totalTrailKms: TextEditingController(text: json['totalTrailKms'] ?? ""),
      fuelConsumed: TextEditingController(text: json['fuelConsumed'] ?? ""),
      adBlueConsumedCluster:
          TextEditingController(text: json['adBlueConsumedCluster'] ?? ""),
      didRegenerationHappen:
          (json['didRegenerationHappen'] ?? false).toString() == 'true'
              ? true.obs
              : false.obs,
      leadDistance: TextEditingController(text: json['leadDistance'] ?? ""),
      drivingSpeed: TextEditingController(text: json['drivingSpeed'] ?? ""),
      actualFeInBB: TextEditingController(text: json['actualFeInBB'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleRegNo': vehicleRegNo.text,
      'brand': brand.text,
      'chassisNo': chassisNo.text,
      'vehicleModel': vehicleModel.text,
      'wheelBase': wheelBase.text,
      'atsType': atsType.text,
      'emission': emission.text,
      'tyreBrand': tyreBrand.text,
      'application': application.text,
      'gvwCarried': gvwCarried.text,
      'tripStartDate': tripStartDate.text,
      'startOdo': startOdo.text,
      'tripFinishDate': tripFinishDate.text,
      'endOdo': endOdo.text,
      'startPlace': startPlace.text,
      'endPlace': endPlace.text,
      'totalTrailKms': totalTrailKms.text,
      'fuelConsumed': fuelConsumed.text,
      'adBlueConsumedCluster': adBlueConsumedCluster.text,
      'didRegenerationHappen': didRegenerationHappen.value,
      'leadDistance': leadDistance.text,
      'drivingSpeed': drivingSpeed.text,
      'actualFeInBB': actualFeInBB.text,
    };
  }

  VehicleDetail copy() {
    return VehicleDetail(
      vehicleRegNo: TextEditingController(text: vehicleRegNo.text),
      brand: TextEditingController(text: brand.text),
      chassisNo: TextEditingController(text: chassisNo.text),
      vehicleModel: TextEditingController(text: vehicleModel.text),
      wheelBase: TextEditingController(text: wheelBase.text),
      atsType: TextEditingController(text: atsType.text),
      emission: TextEditingController(text: emission.text),
      tyreBrand: TextEditingController(text: tyreBrand.text),
      application: TextEditingController(text: application.text),
      gvwCarried: TextEditingController(text: gvwCarried.text),
      tripStartDate: TextEditingController(text: tripStartDate.text),
      startOdo: TextEditingController(text: startOdo.text),
      tripFinishDate: TextEditingController(text: tripFinishDate.text),
      endOdo: TextEditingController(text: endOdo.text),
      startPlace: TextEditingController(text: startPlace.text),
      endPlace: TextEditingController(text: endPlace.text),
      totalTrailKms: TextEditingController(text: totalTrailKms.text),
      fuelConsumed: TextEditingController(text: fuelConsumed.text),
      adBlueConsumedCluster:
          TextEditingController(text: adBlueConsumedCluster.text),
      didRegenerationHappen: didRegenerationHappen.value.obs,
      leadDistance: TextEditingController(text: leadDistance.text),
      drivingSpeed: TextEditingController(text: drivingSpeed.text),
      actualFeInBB: TextEditingController(text: actualFeInBB.text),
    );
  }
}

class FormSubmissionModel {
  int? id;
  String location;
  String date;
  String masterDriverName;
  String empCode;
  String mobileNo;
  String customerDriverName;
  String customerMobileNo;
  String licenseNo;
  List<VehicleDetail> vehicleDetails;
  List<VehicleDetail> competitorData;
  List<String> imageVideoUrls;

  FormSubmissionModel(
      {this.id,
      required this.location,
      required this.date,
      required this.masterDriverName,
      required this.empCode,
      required this.mobileNo,
      required this.customerDriverName,
      required this.customerMobileNo,
      required this.licenseNo,
      required this.vehicleDetails,
      required this.competitorData,
      required this.imageVideoUrls});

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json) =>
      FormSubmissionModel(
        id: json['id'] ?? 0,
        location: json['location'] ?? "",
        date: json['date'] ?? "",
        masterDriverName: json['masterDriverName'] ?? "",
        empCode: json['empCode'] ?? "",
        mobileNo: json['mobileNo'] ?? "",
        customerDriverName: json['customerDriverName'] ?? "",
        customerMobileNo: json['customerMobileNo'] ?? "",
        licenseNo: json['licenseNo'] ?? "",
        vehicleDetails: (json['vehicleDetails'] as List?)
                ?.map((item) => VehicleDetail.fromJson(item))
                .toList() ??
            [],
        competitorData: (json['competitorData'] as List?)
                ?.map((item) => VehicleDetail.fromJson(item))
                .toList() ??
            [],
        imageVideoUrls: (json['imageVideoUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'location': location,
        'date': date,
        'masterDriverName': masterDriverName,
        'empCode': empCode,
        'mobileNo': mobileNo,
        'customerDriverName': customerDriverName,
        'customerMobileNo': customerMobileNo,
        'licenseNo': licenseNo,
        'vehicleDetails':
            vehicleDetails.map((vehicle) => vehicle.toJson()).toList(),
        'competitorData':
            competitorData.map((vehicle) => vehicle.toJson()).toList(),
        'imageVideoUrls': imageVideoUrls
      };
}
