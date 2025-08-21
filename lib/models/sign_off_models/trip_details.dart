class TripDetail {
  int? id;
  int? signOffId;
  int tripNo; // 1..6 (6 = overall)
  String? tripRoute;
  String? tripStartDate;
  String? tripEndDate;
  double? startKm;
  double? endKm;
  double? tripKm;
  double? maxSpeed;
  double? weightGVW;
  double? actualDieselLtrs;
  double? totalTripKm;
  double? actualFE;

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
  });

  Map<String, dynamic> toJson() => {
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

  factory TripDetail.fromJson(Map<String, dynamic> j) => TripDetail(
    id: j['id'],
    signOffId: j['signOffId'],
    tripNo: j['tripNo'],
    tripRoute: j['tripRoute'],
    tripStartDate: j['tripStartDate'],
    tripEndDate: j['tripEndDate'],
    startKm: (j['startKm'] as num?)?.toDouble(),
    endKm: (j['endKm'] as num?)?.toDouble(),
    tripKm: (j['tripKm'] as num?)?.toDouble(),
    maxSpeed: (j['maxSpeed'] as num?)?.toDouble(),
    weightGVW: (j['weightGVW'] as num?)?.toDouble(),
    actualDieselLtrs: (j['actualDieselLtrs'] as num?)?.toDouble(),
    totalTripKm: (j['totalTripKm'] as num?)?.toDouble(),
    actualFE: (j['actualFE'] as num?)?.toDouble(),
  );
}