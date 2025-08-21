// lib/models/photo.dart
class Photo {
  int? id;
  int? signOffId;
  String fileUrl;
  String? caption;

  Photo({ this.id, this.signOffId, required this.fileUrl, this.caption });

  Map<String, dynamic> toJson() => {
    'fileUrl': fileUrl,
    'caption': caption,
  };

  factory Photo.fromJson(Map<String, dynamic> j) => Photo(
    id: j['id'],
    signOffId: j['signOffId'],
    fileUrl: j['fileUrl'],
    caption: j['caption'],
  );
}