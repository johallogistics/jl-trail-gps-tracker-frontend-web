import 'dart:convert';

class TrailResponse {
  final String message;
  final TrailPayload payload;

  TrailResponse({
    required this.message,
    required this.payload,
  });

  factory TrailResponse.fromJson(Map<String, dynamic> json) =>
      TrailResponse.fromMap(json);

  factory TrailResponse.fromMap(Map<String, dynamic> json) => TrailResponse(
    message: json["message"] ?? "",
    payload: TrailPayload.fromMap(json["payload"] ?? []), // Correctly parse the payload as a list
  );

  Map<String, dynamic> toMap() => {
    "message": message,
    "payload": payload.toMap(),
  };
}

class TrailPayload {
  final List<Trail> trails;

  TrailPayload({required this.trails});

  factory TrailPayload.fromMap(dynamic json) => TrailPayload(
    trails: (json as List<dynamic>)
        .map((x) => Trail.fromMap(x))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    "trails": trails.map((x) => x.toMap()).toList(),
  };
}

class Trail {
  final int id;
  final String vehicleRegNo;
  final String vehicleModel;
  final String brand;
  final String startOdo;
  final String endOdo;
  final String startPlace;
  final String endPlace;
  final String fuelConsumed;
  final String tripStartDate;
  final String tripFinishDate;
  final String location;
  final String date;
  final String masterDriverName;
  final String empCode;
  final String mobileNo;
  final String customerDriverName;
  final String customerMobileNo;

  Trail({
    required this.id,
    required this.vehicleRegNo,
    required this.vehicleModel,
    required this.brand,
    required this.startOdo,
    required this.endOdo,
    required this.startPlace,
    required this.endPlace,
    required this.fuelConsumed,
    required this.tripStartDate,
    required this.tripFinishDate,
    required this.location,
    required this.date,
    required this.masterDriverName,
    required this.empCode,
    required this.mobileNo,
    required this.customerDriverName,
    required this.customerMobileNo,
  });

  factory Trail.fromMap(Map<String, dynamic> json) => Trail(
    id: json["id"] ?? 0,  // Now we handle it as an int
    vehicleRegNo: json["vehicleRegNo"] ?? "",
    vehicleModel: json["vehicleModel"] ?? "",
    brand: json["brand"] ?? "",
    startOdo: json["startOdo"] ?? "",
    endOdo: json["endOdo"] ?? "",
    startPlace: json["startPlace"] ?? "",
    endPlace: json["endPlace"] ?? "",
    fuelConsumed: json["fuelConsumed"] ?? "",
    tripStartDate: json["tripStartDate"] ?? "",
    tripFinishDate: json["tripFinishDate"] ?? "",
    location: json["location"] ?? "",
    date: json["date"] ?? "",
    masterDriverName: json["masterDriverName"] ?? "",
    empCode: json["empCode"] ?? "",
    mobileNo: json["mobileNo"] ?? "",
    customerDriverName: json["customerDriverName"] ?? "",
    customerMobileNo: json["customerMobileNo"] ?? "",
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "vehicleRegNo": vehicleRegNo,
    "vehicleModel": vehicleModel,
    "brand": brand,
    "startOdo": startOdo,
    "endOdo": endOdo,
    "startPlace": startPlace,
    "endPlace": endPlace,
    "fuelConsumed": fuelConsumed,
    "tripStartDate": tripStartDate,
    "tripFinishDate": tripFinishDate,
    "location": location,
    "date": date,
    "masterDriverName": masterDriverName,
    "empCode": empCode,
    "mobileNo": mobileNo,
    "customerDriverName": customerDriverName,
    "customerMobileNo": customerMobileNo,
  };
}


class TrailRequest {
  final String? vehicleRegNo;
  final String? vehicleModel;
  final String? brand;
  final String? startOdo;
  final String? endOdo;
  final String? startPlace;
  final String? endPlace;
  final String? fuelConsumed;
  final String? tripStartDate;
  final String? tripFinishDate;
  final String? location;
  final String? date;
  final String? masterDriverName;
  final String? empCode;
  final String? mobileNo;
  final String? customerDriverName;
  final String? customerMobileNo;

  TrailRequest({
    this.vehicleRegNo,
    this.vehicleModel,
    this.brand,
    this.startOdo,
    this.endOdo,
    this.startPlace,
    this.endPlace,
    this.fuelConsumed,
    this.tripStartDate,
    this.tripFinishDate,
    this.location,
    this.date,
    this.masterDriverName,
    this.empCode,
    this.mobileNo,
    this.customerDriverName,
    this.customerMobileNo,
  });

  Map<String, dynamic> toMap() => {
    "vehicleRegNo": vehicleRegNo,
    "vehicleModel": vehicleModel,
    "brand": brand,
    "startOdo": startOdo,
    "endOdo": endOdo,
    "startPlace": startPlace,
    "endPlace": endPlace,
    "fuelConsumed": fuelConsumed,
    "tripStartDate": tripStartDate,
    "tripFinishDate": tripFinishDate,
    "location": location,
    "date": date,
    "masterDriverName": masterDriverName,
    "empCode": empCode,
    "mobileNo": mobileNo,
    "customerDriverName": customerDriverName,
    "customerMobileNo": customerMobileNo,
  };
}


