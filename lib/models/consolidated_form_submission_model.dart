import 'package:get/get_rx/src/rx_types/rx_types.dart';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

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

  // Factory method for creating an instance of VehicleDetail from JSON
  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    return VehicleDetail(
      vehicleRegNo: TextEditingController(text: json['vehicleRegNo']),
      brand: TextEditingController(text: json['brand']),
      chassisNo: TextEditingController(text: json['chassisNo']),
      vehicleModel: TextEditingController(text: json['vehicleModel']),
      wheelBase: TextEditingController(text: json['wheelBase']),
      atsType: TextEditingController(text: json['atsType']),
      emission: TextEditingController(text: json['emission']),
      tyreBrand: TextEditingController(text: json['tyreBrand']),
      application: TextEditingController(text: json['application']),
      gvwCarried: TextEditingController(text: json['gvwCarried']),
      tripStartDate: TextEditingController(text: json['tripStartDate']),
      startOdo: TextEditingController(text: json['startOdo']),
      tripFinishDate: TextEditingController(text: json['tripFinishDate']),
      endOdo: TextEditingController(text: json['endOdo']),
      startPlace: TextEditingController(text: json['startPlace']),
      endPlace: TextEditingController(text: json['endPlace']),
      totalTrailKms: TextEditingController(text: json['totalTrailKms']),
      fuelConsumed: TextEditingController(text: json['fuelConsumed']),
      adBlueConsumedCluster: TextEditingController(text: json['adBlueConsumedCluster']),
      didRegenerationHappen: (json['didRegenerationHappen'] ?? false).obs,
      leadDistance: TextEditingController(text: json['leadDistance']),
      drivingSpeed: TextEditingController(text: json['drivingSpeed']),
      actualFeInBB: TextEditingController(text: json['actualFeInBB']),
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
}




class FormSubmissionModel {
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

  FormSubmissionModel({
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
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'date': date,
      'masterDriverName': masterDriverName,
      'empCode': empCode,
      'mobileNo': mobileNo,
      'customerDriverName': customerDriverName,
      'customerMobileNo': customerMobileNo,
      'licenseNo': licenseNo,
      'vehicleDetails': vehicleDetails.map((vehicle) => vehicle.toJson()).toList(),
      'competitorData': competitorData.map((vehicle) => vehicle.toJson()).toList(),
    };
  }
}
