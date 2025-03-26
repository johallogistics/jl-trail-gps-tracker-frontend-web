class Location {
  final String id;
  final String driverId;
  final String phone;
  final double latitude;
  final double longitude;
  final String timestamp;

  Location({
    required this.id,
    required this.driverId,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      driverId: json['driverId'],
      phone: json['phone'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      timestamp: json['timestamp'],
    );
  }
}
