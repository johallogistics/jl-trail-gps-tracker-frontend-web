class Location {
  final String id;
  final String phone;
  final double latitude;
  final double longitude;
  final bool isIdle;
  final DateTime timestamp;

  Location({
    required this.id,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.isIdle,
    required this.timestamp,
  });

  /// ✅ Null-safe `fromJson()` method
  factory Location.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception("Invalid JSON: null received");
    }

    return Location(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isIdle: json['isIdle'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'latitude': latitude,
    'longitude': longitude,
    'isIdle': isIdle,
    'timestamp': timestamp.toIso8601String(),
  };
}
