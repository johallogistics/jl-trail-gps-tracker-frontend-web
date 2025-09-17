// lib/models/participant.dart
class ParticipantSignOff {
  String? id;
  int? signOffId;
  String role; // 'CSM','PC','DRIVER','CUSTOMER'
  String? name;
  String? signatureUrl;

  ParticipantSignOff({ this.id, this.signOffId, required this.role, this.name, this.signatureUrl });

  Map<String, dynamic> toJson() => {
    'role': role,
    'name': name,
    'signatureUrl': signatureUrl,
  };

  factory ParticipantSignOff.fromJson(Map<String, dynamic> j) => ParticipantSignOff(
    id: j['id'],
    signOffId: j['signOffId'],
    role: j['role'],
    name: j['name'],
    signatureUrl: j['signatureUrl'],
  );
}