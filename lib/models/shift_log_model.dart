import 'dart:convert';

import 'dart:convert';

class ShiftLog {
  final int? id;

  // Timing
  final String shift;
  final int otHours;
  final DateTime inTime;
  final DateTime outTime;
  final int workingHours;
  final String monthYear;

  // Vehicle
  final String vehicleModel;
  final String regNo;
  final String chassisNo;
  final double gvw;
  final double payload;
  final int startingKm;
  final int endingKm;
  final int totalKm;
  final double fuelAvg;
  final double previousKmpl;
  final double clusterKmpl;
  final double highwaySweetSpotPercent;
  final double normalRoadSweetSpotPercent;
  final double hillsRoadSweetSpotPercent;
  final String trialKMPL;
  final String vehicleOdometerStartingReading;
  final String vehicleOdometerEndingReading;
  final String trialKMS;
  final String trialAllocation;

  // Trial info
  final String purposeOfTrial;
  final String reason;
  final String dateOfSale;
  final String trailId;

  // Location
  final String fromPlace;
  final String toPlace;
  final String presentLocation;

  // Personnel
  final String employeeName;
  final String vecvReportingPerson;
  final String employeePhoneNo;
  final String employeeCode;
  final String dicvInchargeName;
  final String dicvInchargePhoneNo;

  // Customer & Dealer
  final String dealerName;
  final String customerName;
  final String customerDriverName;
  final String customerDriverNo;
  final String capitalizedVehicleOrCustomerVehicle;
  final String customerVehicle;
  final String capitalizedVehicle;
  final String vehicleNo;

  // Driver
  final String coDriverName;
  final String coDriverPhoneNo;
  final String driverStatus;

  // Media
  final List<String> imageVideoUrls;
  final String inchargeSign;

  final DateTime createdAt;
  final DateTime updatedAt;

  ShiftLog({
    this.id,
    required this.shift,
    required this.otHours,
    required this.inTime,
    required this.outTime,
    required this.workingHours,
    required this.monthYear,
    required this.vehicleModel,
    required this.regNo,
    required this.chassisNo,
    required this.gvw,
    required this.payload,
    required this.startingKm,
    required this.endingKm,
    required this.totalKm,
    required this.fuelAvg,
    required this.previousKmpl,
    required this.clusterKmpl,
    required this.highwaySweetSpotPercent,
    required this.normalRoadSweetSpotPercent,
    required this.hillsRoadSweetSpotPercent,
    required this.trialKMPL,
    required this.vehicleOdometerStartingReading,
    required this.vehicleOdometerEndingReading,
    required this.trialKMS,
    required this.trialAllocation,
    required this.purposeOfTrial,
    required this.reason,
    required this.dateOfSale,
    required this.trailId,
    required this.fromPlace,
    required this.toPlace,
    required this.presentLocation,
    required this.employeeName,
    required this.vecvReportingPerson,
    required this.employeePhoneNo,
    required this.employeeCode,
    required this.dicvInchargeName,
    required this.dicvInchargePhoneNo,
    required this.dealerName,
    required this.customerName,
    required this.customerDriverName,
    required this.customerDriverNo,
    required this.capitalizedVehicleOrCustomerVehicle,
    required this.customerVehicle,
    required this.capitalizedVehicle,
    required this.vehicleNo,
    required this.coDriverName,
    required this.coDriverPhoneNo,
    required this.driverStatus,
    required this.imageVideoUrls,
    required this.inchargeSign,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShiftLog.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(String? input) {
      try {
        return DateTime.parse(input ?? '').toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    return ShiftLog(
      id: json['id'],
      shift: json['shift'],
      otHours: json['otHours'],
      inTime: _parseDate(json['inTime']),
      outTime: _parseDate(json['outTime']),
      workingHours: json['workingHours'],
      monthYear: json['monthYear'],
      vehicleModel: json['vehicleModel'],
      regNo: json['regNo'],
      chassisNo: json['chassisNo'],
      gvw: (json['gvw'] as num).toDouble(),
      payload: (json['payload'] as num).toDouble(),
      startingKm: json['startingKm'],
      endingKm: json['endingKm'],
      totalKm: json['totalKm'],
      fuelAvg: (json['fuelAvg'] as num).toDouble(),
      previousKmpl: (json['previousKmpl'] as num).toDouble(),
      clusterKmpl: (json['clusterKmpl'] as num).toDouble(),
      highwaySweetSpotPercent: (json['highwaySweetSpotPercent'] as num).toDouble(),
      normalRoadSweetSpotPercent: (json['normalRoadSweetSpotPercent'] as num).toDouble(),
      hillsRoadSweetSpotPercent: (json['hillsRoadSweetSpotPercent'] as num).toDouble(),
      trialKMPL: json['trialKMPL'],
      vehicleOdometerStartingReading: json['vehicleOdometerStartingReading'],
      vehicleOdometerEndingReading: json['vehicleOdometerEndingReading'],
      trialKMS: json['trialKMS'],
      trialAllocation: json['trialAllocation'],
      purposeOfTrial: json['purposeOfTrial'],
      reason: json['reason'],
      dateOfSale: json['dateOfSale'],
      trailId: json['trailId'],
      fromPlace: json['fromPlace'],
      toPlace: json['toPlace'],
      presentLocation: json['presentLocation'],
      employeeName: json['employeeName'],
      vecvReportingPerson: json['vecvReportingPerson'],
      employeePhoneNo: json['employeePhoneNo'],
      employeeCode: json['employeeCode'],
      dicvInchargeName: json['dicvInchargeName'],
      dicvInchargePhoneNo: json['dicvInchargePhoneNo'],
      dealerName: json['dealerName'],
      customerName: json['customerName'],
      customerDriverName: json['customerDriverName'],
      customerDriverNo: json['customerDriverNo'],
      capitalizedVehicleOrCustomerVehicle: json['capitalizedVehicleOrCustomerVehicle'],
      customerVehicle: json['customerVehicle'],
      capitalizedVehicle: json['capitalizedVehicle'],
      vehicleNo: json['vehicleNo'],
      coDriverName: json['coDriverName'],
      coDriverPhoneNo: json['coDriverPhoneNo'],
      driverStatus: json['driverStatus'],
      imageVideoUrls: (json['imageVideoUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      inchargeSign: json['inchargeSign'],
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonWithoutId() {
    return {
      'shift': shift,
      'otHours': otHours,
      'vehicleModel': vehicleModel,
      'regNo': regNo,
      'chassisNo': chassisNo,
      'gvw': gvw,
      'payload': payload,
      'inTime': inTime.toIso8601String(),
      'outTime': outTime.toIso8601String(),
      'workingHours': workingHours,
      'startingKm': startingKm,
      'endingKm': endingKm,
      'totalKm': totalKm,
      'fromPlace': fromPlace,
      'toPlace': toPlace,
      'presentLocation': presentLocation,
      'fuelAvg': fuelAvg,
      'previousKmpl': previousKmpl,
      'clusterKmpl': clusterKmpl,
      'highwaySweetSpotPercent': highwaySweetSpotPercent,
      'normalRoadSweetSpotPercent': normalRoadSweetSpotPercent,
      'hillsRoadSweetSpotPercent': hillsRoadSweetSpotPercent,
      'trialKMPL': trialKMPL,
      'vehicleOdometerStartingReading': vehicleOdometerStartingReading,
      'vehicleOdometerEndingReading': vehicleOdometerEndingReading,
      'trialKMS': trialKMS,
      'trialAllocation': trialAllocation,
      'coDriverName': coDriverName,
      'coDriverPhoneNo': coDriverPhoneNo,
      'inchargeSign': inchargeSign,
      'employeeName': employeeName,
      'employeePhoneNo': employeePhoneNo,
      'employeeCode': employeeCode,
      'monthYear': monthYear,
      'dicvInchargeName': dicvInchargeName,
      'dicvInchargePhoneNo': dicvInchargePhoneNo,
      'vecvReportingPerson': vecvReportingPerson,
      'dealerName': dealerName,
      'customerName': customerName,
      'customerDriverName': customerDriverName,
      'customerDriverNo': customerDriverNo,
      'capitalizedVehicleOrCustomerVehicle': capitalizedVehicleOrCustomerVehicle,
      'customerVehicle': customerVehicle,
      'capitalizedVehicle': capitalizedVehicle,
      'vehicleNo': vehicleNo,
      'driverStatus': driverStatus,
      'purposeOfTrial': purposeOfTrial,
      'reason': reason,
      'dateOfSale': dateOfSale,
      'trailId': trailId,
      'imageVideoUrls': imageVideoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift': shift,
      'otHours': otHours,
      'inTime': inTime.toIso8601String(),
      'outTime': outTime.toIso8601String(),
      'workingHours': workingHours,
      'monthYear': monthYear,
      'vehicleModel': vehicleModel,
      'regNo': regNo,
      'chassisNo': chassisNo,
      'gvw': gvw,
      'payload': payload,
      'startingKm': startingKm,
      'endingKm': endingKm,
      'totalKm': totalKm,
      'fuelAvg': fuelAvg,
      'previousKmpl': previousKmpl,
      'clusterKmpl': clusterKmpl,
      'highwaySweetSpotPercent': highwaySweetSpotPercent,
      'normalRoadSweetSpotPercent': normalRoadSweetSpotPercent,
      'hillsRoadSweetSpotPercent': hillsRoadSweetSpotPercent,
      'trialKMPL': trialKMPL,
      'vehicleOdometerStartingReading': vehicleOdometerStartingReading,
      'vehicleOdometerEndingReading': vehicleOdometerEndingReading,
      'trialKMS': trialKMS,
      'trialAllocation': trialAllocation,
      'purposeOfTrial': purposeOfTrial,
      'reason': reason,
      'dateOfSale': dateOfSale,
      'trailId': trailId,
      'fromPlace': fromPlace,
      'toPlace': toPlace,
      'presentLocation': presentLocation,
      'employeeName': employeeName,
      'vecvReportingPerson': vecvReportingPerson,
      'employeePhoneNo': employeePhoneNo,
      'employeeCode': employeeCode,
      'dicvInchargeName': dicvInchargeName,
      'dicvInchargePhoneNo': dicvInchargePhoneNo,
      'dealerName': dealerName,
      'customerName': customerName,
      'customerDriverName': customerDriverName,
      'customerDriverNo': customerDriverNo,
      'capitalizedVehicleOrCustomerVehicle': capitalizedVehicleOrCustomerVehicle,
      'customerVehicle': customerVehicle,
      'capitalizedVehicle': capitalizedVehicle,
      'vehicleNo': vehicleNo,
      'coDriverName': coDriverName,
      'coDriverPhoneNo': coDriverPhoneNo,
      'driverStatus': driverStatus,
      'imageVideoUrls': imageVideoUrls,
      'inchargeSign': inchargeSign,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}


/// Model for handling the API response
class ShiftLogResponse {
  final String message;
  final ShiftLog payload;

  ShiftLogResponse({required this.message, required this.payload});

  factory ShiftLogResponse.fromJson(Map<String, dynamic> json) {
    return ShiftLogResponse(
      message: json['message'],
      payload: ShiftLog.fromJson(json['payload']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'payload': payload.toJson(),
    };
  }

}
