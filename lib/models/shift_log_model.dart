class ShiftLog {
  final int? id;
  // Timing
  final String shift;
  final String? date;
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
  final String trialAllocation; // existing

  // NEW allocation (distinct from trialAllocation)
  final String allocation;

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

  // NEW optional region
  final String? region;

  final DateTime createdAt;
  final DateTime updatedAt;

  ShiftLog({
    this.id,
    required this.shift,
    required this.date,
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
    required this.allocation, // new
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
    this.region,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShiftLog.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic input) {
      try {
        if (input == null) return DateTime.now();
        return DateTime.parse(input.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      try {
        return double.parse(v.toString());
      } catch (_) {
        return 0.0;
      }
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      try {
        return int.parse(v.toString());
      } catch (_) {
        return 0;
      }
    }

    String _toString(dynamic v) => v?.toString() ?? '';

    return ShiftLog(
      id: json['id'] is int ? json['id'] as int : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      shift: _toString(json['shift']),
      date: _toString(json['date']),
      otHours: _toInt(json['otHours']),
      inTime: _parseDate(json['inTime']),
      outTime: _parseDate(json['outTime']),
      workingHours: _toInt(json['workingHours']),
      monthYear: _toString(json['monthYear']),
      vehicleModel: _toString(json['vehicleModel']),
      regNo: _toString(json['regNo']),
      chassisNo: _toString(json['chassisNo']),
      gvw: _toDouble(json['gvw']),
      payload: _toDouble(json['payload']),
      startingKm: _toInt(json['startingKm']),
      endingKm: _toInt(json['endingKm']),
      totalKm: _toInt(json['totalKm']),
      fuelAvg: _toDouble(json['fuelAvg']),
      previousKmpl: _toDouble(json['previousKmpl']),
      clusterKmpl: _toDouble(json['clusterKmpl']),
      highwaySweetSpotPercent: _toDouble(json['highwaySweetSpotPercent']),
      normalRoadSweetSpotPercent: _toDouble(json['normalRoadSweetSpotPercent']),
      hillsRoadSweetSpotPercent: _toDouble(json['hillsRoadSweetSpotPercent']),
      trialKMPL: _toString(json['trialKMPL']),
      vehicleOdometerStartingReading: _toString(json['vehicleOdometerStartingReading']),
      vehicleOdometerEndingReading: _toString(json['vehicleOdometerEndingReading']),
      trialKMS: _toString(json['trialKMS']),
      trialAllocation: _toString(json['trialAllocation']),
      allocation: _toString(json['allocation']), // new field
      purposeOfTrial: _toString(json['purposeOfTrial']),
      reason: _toString(json['reason']),
      dateOfSale: _toString(json['dateOfSale']),
      trailId: _toString(json['trailId']),
      fromPlace: _toString(json['fromPlace']),
      toPlace: _toString(json['toPlace']),
      presentLocation: _toString(json['presentLocation']),
      employeeName: _toString(json['employeeName']),
      vecvReportingPerson: _toString(json['vecvReportingPerson']),
      employeePhoneNo: _toString(json['employeePhoneNo']),
      employeeCode: _toString(json['employeeCode']),
      dicvInchargeName: _toString(json['dicvInchargeName']),
      dicvInchargePhoneNo: _toString(json['dicvInchargePhoneNo']),
      dealerName: _toString(json['dealerName']),
      customerName: _toString(json['customerName']),
      customerDriverName: _toString(json['customerDriverName']),
      customerDriverNo: _toString(json['customerDriverNo']),
      capitalizedVehicleOrCustomerVehicle: _toString(json['capitalizedVehicleOrCustomerVehicle']),
      customerVehicle: _toString(json['customerVehicle']),
      capitalizedVehicle: _toString(json['capitalizedVehicle']),
      vehicleNo: _toString(json['vehicleNo']),
      coDriverName: _toString(json['coDriverName']),
      coDriverPhoneNo: _toString(json['coDriverPhoneNo']),
      driverStatus: _toString(json['driverStatus']),
      imageVideoUrls: (json['imageVideoUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      inchargeSign: _toString(json['inchargeSign']),
      region: json.containsKey('region') ? (json['region'] != null ? json['region'].toString() : null) : null,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift': shift,
      'date':date,
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
      'allocation': allocation, // new
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
      'region': region,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonWithoutId() {
    final map = {
      'shift': shift,
      'date': date,
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
      'allocation': allocation, // <-- ✅ NEW FIELD
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
      'region': region, // optional
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    return map;
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
