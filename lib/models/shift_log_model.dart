import 'dart:convert';

class ShiftLog {
  final int id;
  final String shift;
  final int otHours;
  final String vehicleModel;
  final String regNo;
  final DateTime inTime;
  final DateTime outTime;
  final int workingHours;
  final int startingKm;
  final int endingKm;
  final int totalKm;
  final String fromPlace;
  final String toPlace;
  final double fuelAvg;
  final String coDriverName;
  final String coDriverPhoneNo;
  final String inchargeSign;
  final String employeeName;
  final String employeePhoneNo;
  final String employeeCode;
  final String monthYear;
  final String dicvInchargeName;
  final String dicvInchargePhoneNo;
  final String trailId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShiftLog({
    required this.id,
    required this.shift,
    required this.otHours,
    required this.vehicleModel,
    required this.regNo,
    required this.inTime,
    required this.outTime,
    required this.workingHours,
    required this.startingKm,
    required this.endingKm,
    required this.totalKm,
    required this.fromPlace,
    required this.toPlace,
    required this.fuelAvg,
    required this.coDriverName,
    required this.coDriverPhoneNo,
    required this.inchargeSign,
    required this.employeeName,
    required this.employeePhoneNo,
    required this.employeeCode,
    required this.monthYear,
    required this.dicvInchargeName,
    required this.dicvInchargePhoneNo,
    required this.trailId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory method to create an instance from JSON
  factory ShiftLog.fromJson(Map<String, dynamic> json) {
    return ShiftLog(
      id: json['id'],
      shift: json['shift'],
      otHours: json['otHours'],
      vehicleModel: json['vehicleModel'],
      regNo: json['regNo'],
      inTime: DateTime.parse(json['inTime']),
      outTime: DateTime.parse(json['outTime']),
      workingHours: json['workingHours'],
      startingKm: json['startingKm'],
      endingKm: json['endingKm'],
      totalKm: json['totalKm'],
      fromPlace: json['fromPlace'],
      toPlace: json['toPlace'],
      fuelAvg: (json['fuelAvg'] as num).toDouble(),
      coDriverName: json['coDriverName'],
      coDriverPhoneNo: json['coDriverPhoneNo'],
      inchargeSign: json['inchargeSign'],
      employeeName: json['employeeName'],
      employeePhoneNo: json['employeePhoneNo'],
      employeeCode: json['employeeCode'],
      monthYear: json['monthYear'],
      dicvInchargeName: json['dicvInchargeName'],
      dicvInchargePhoneNo: json['dicvInchargePhoneNo'],
      trailId: json['trailId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift': shift,
      'otHours': otHours,
      'vehicleModel': vehicleModel,
      'regNo': regNo,
      'inTime': inTime.toIso8601String(),
      'outTime': outTime.toIso8601String(),
      'workingHours': workingHours,
      'startingKm': startingKm,
      'endingKm': endingKm,
      'totalKm': totalKm,
      'fromPlace': fromPlace,
      'toPlace': toPlace,
      'fuelAvg': fuelAvg,
      'coDriverName': coDriverName,
      'coDriverPhoneNo': coDriverPhoneNo,
      'inchargeSign': inchargeSign,
      'employeeName': employeeName,
      'employeePhoneNo': employeePhoneNo,
      'employeeCode': employeeCode,
      'monthYear': monthYear,
      'dicvInchargeName': dicvInchargeName,
      'dicvInchargePhoneNo': dicvInchargePhoneNo,
      'trailId': trailId,
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
