class TrialForm {
  int? id;
  String? customerName;
  double? customerExpectedFe;
  double? beforeTrialsFe;
  double? afterTrialsFe;
  String? tripDuration;
  String? vehicleNo;
  DateTime? saleDate;
  String? model;
  String? application;
  String? customerVerbatim;
  String? tripRoute;
  String? issuesFoundOnVehicleCheck;
  String? roadType;
  DateTime? vehicleCheckDate;
  String? customerRemarks;

  List<Participant>? participants;
  List<Trip>? trips;
  List<Photo>? photos;

  TrialForm({
    this.id,
    this.customerName,
    this.customerExpectedFe,
    this.beforeTrialsFe,
    this.afterTrialsFe,
    this.tripDuration,
    this.vehicleNo,
    this.saleDate,
    this.model,
    this.application,
    this.customerVerbatim,
    this.tripRoute,
    this.issuesFoundOnVehicleCheck,
    this.roadType,
    this.vehicleCheckDate,
    this.customerRemarks,
    this.participants,
    this.trips,
    this.photos,
  });

  factory TrialForm.fromJson(Map<String, dynamic> json) => TrialForm(
    id: json["id"],
    customerName: json["customer_name"],
    customerExpectedFe: (json["customer_expected_fe"] as num?)?.toDouble(),
    beforeTrialsFe: (json["before_trials_fe"] as num?)?.toDouble(),
    afterTrialsFe: (json["after_trials_fe"] as num?)?.toDouble(),
    tripDuration: json["trip_duration"],
    vehicleNo: json["vehicle_no"],
    saleDate: json["sale_date"] != null ? DateTime.parse(json["sale_date"]) : null,
    model: json["model"],
    application: json["application"],
    customerVerbatim: json["customer_verbatim"],
    tripRoute: json["trip_route"],
    issuesFoundOnVehicleCheck: json["issues_found_on_vehicle_check"],
    roadType: json["road_type"],
    vehicleCheckDate: json["vehicle_check_date"] != null ? DateTime.parse(json["vehicle_check_date"]) : null,
    customerRemarks: json["customer_remarks"],
    participants: (json["participants"] as List<dynamic>?)
        ?.map((e) => Participant.fromJson(e))
        .toList(),
    trips: (json["trips"] as List<dynamic>?)
        ?.map((e) => Trip.fromJson(e))
        .toList(),
    photos: (json["photos"] as List<dynamic>?)
        ?.map((e) => Photo.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customer_name": customerName,
    "customer_expected_fe": customerExpectedFe,
    "before_trials_fe": beforeTrialsFe,
    "after_trials_fe": afterTrialsFe,
    "trip_duration": tripDuration,
    "vehicle_no": vehicleNo,
    "sale_date": saleDate?.toIso8601String(),
    "model": model,
    "application": application,
    "customer_verbatim": customerVerbatim,
    "trip_route": tripRoute,
    "issues_found_on_vehicle_check": issuesFoundOnVehicleCheck,
    "road_type": roadType,
    "vehicle_check_date": vehicleCheckDate?.toIso8601String(),
    "customer_remarks": customerRemarks,
    "participants": participants?.map((e) => e.toJson()).toList(),
    "trips": trips?.map((e) => e.toJson()).toList(),
    "photos": photos?.map((e) => e.toJson()).toList(),
  };

  TrialForm copyWith({
    int? id,
    String? customerName,
    double? customerExpectedFe,
    double? beforeTrialsFe,
    double? afterTrialsFe,
    String? tripDuration,
    String? vehicleNo,
    DateTime? saleDate,
    String? model,
    String? application,
    String? customerVerbatim,
    String? tripRoute,
    String? issuesFoundOnVehicleCheck,
    String? roadType,
    DateTime? vehicleCheckDate,
    String? customerRemarks,
    List<Participant>? participants,
    List<Trip>? trips,
    List<Photo>? photos,
  }) {
    return TrialForm(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerExpectedFe: customerExpectedFe ?? this.customerExpectedFe,
      beforeTrialsFe: beforeTrialsFe ?? this.beforeTrialsFe,
      afterTrialsFe: afterTrialsFe ?? this.afterTrialsFe,
      tripDuration: tripDuration ?? this.tripDuration,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      saleDate: saleDate ?? this.saleDate,
      model: model ?? this.model,
      application: application ?? this.application,
      customerVerbatim: customerVerbatim ?? this.customerVerbatim,
      tripRoute: tripRoute ?? this.tripRoute,
      issuesFoundOnVehicleCheck: issuesFoundOnVehicleCheck ?? this.issuesFoundOnVehicleCheck,
      roadType: roadType ?? this.roadType,
      vehicleCheckDate: vehicleCheckDate ?? this.vehicleCheckDate,
      customerRemarks: customerRemarks ?? this.customerRemarks,
      participants: participants ?? this.participants,
      trips: trips ?? this.trips,
      photos: photos ?? this.photos,
    );
  }

}

class Participant {
  int? id;
  int? trialFormId;
  String? role;
  String? name;
  String? sign;

  Participant({
    this.id,
    this.trialFormId,
    this.role,
    this.name,
    this.sign,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"],
    trialFormId: json["trial_form_id"],
    role: json["role"],
    name: json["name"],
    sign: json["sign"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "trial_form_id": trialFormId,
    "role": role,
    "name": name,
    "sign": sign,
  };
}

class Trip {
  int? id;
  int? trialFormId;
  String? tripNo;
  String? tripRoute;
  DateTime? tripStartDate;
  DateTime? tripEndDate;
  double? startKm;
  double? endKm;
  double? tripKm;
  double? maxSpeed;
  double? weightGvw;
  double? actualDieselLtrs;
  double? totalTripKm;
  double? actualFeKmpl;
  String? issuesFound;
  String? trialRemarks;

  Trip({
    this.id,
    this.trialFormId,
    this.tripNo,
    this.tripRoute,
    this.tripStartDate,
    this.tripEndDate,
    this.startKm,
    this.endKm,
    this.tripKm,
    this.maxSpeed,
    this.weightGvw,
    this.actualDieselLtrs,
    this.totalTripKm,
    this.actualFeKmpl,
    this.issuesFound,
    this.trialRemarks,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json["id"],
    trialFormId: json["trial_form_id"],
    tripNo: json["trip_no"],
    tripRoute: json["trip_route"],
    tripStartDate: json["trip_start_date"] != null ? DateTime.parse(json["trip_start_date"]) : null,
    tripEndDate: json["trip_end_date"] != null ? DateTime.parse(json["trip_end_date"]) : null,
    startKm: (json["start_km"] as num?)?.toDouble(),
    endKm: (json["end_km"] as num?)?.toDouble(),
    tripKm: (json["trip_km"] as num?)?.toDouble(),
    maxSpeed: (json["max_speed"] as num?)?.toDouble(),
    weightGvw: (json["weight_gvw"] as num?)?.toDouble(),
    actualDieselLtrs: (json["actual_diesel_ltrs"] as num?)?.toDouble(),
    totalTripKm: (json["total_trip_km"] as num?)?.toDouble(),
    actualFeKmpl: (json["actual_fe_kmpl"] as num?)?.toDouble(),
    issuesFound: json["issues_found"],
    trialRemarks: json["trial_remarks"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "trial_form_id": trialFormId,
    "trip_no": tripNo,
    "trip_route": tripRoute,
    "trip_start_date": tripStartDate?.toIso8601String(),
    "trip_end_date": tripEndDate?.toIso8601String(),
    "start_km": startKm,
    "end_km": endKm,
    "trip_km": tripKm,
    "max_speed": maxSpeed,
    "weight_gvw": weightGvw,
    "actual_diesel_ltrs": actualDieselLtrs,
    "total_trip_km": totalTripKm,
    "actual_fe_kmpl": actualFeKmpl,
    "issues_found": issuesFound,
    "trial_remarks": trialRemarks,
  };
}

class Photo {
  int? id;
  int? trialFormId;
  String? url;

  Photo({this.id, this.trialFormId, this.url});

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    id: json["id"],
    trialFormId: json["trial_form_id"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "trial_form_id": trialFormId,
    "url": url,
  };
}
