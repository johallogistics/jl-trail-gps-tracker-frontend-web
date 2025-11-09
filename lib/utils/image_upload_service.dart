import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // 👈 for MediaType
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../api/api_manager.dart';

const String backendBase = ApiManager.baseUrl; // e.g. https://your-host/api

class UploadedDocument {
  final String id;
  final String key;
  final String url;         // backend download/stream URL (e.g. /api/files/download?key=...)
  final String contentType;
  final int? size;

  UploadedDocument({
    required this.id,
    required this.key,
    required this.url,
    required this.contentType,
    this.size,
  });

  factory UploadedDocument.fromJson(Map<String, dynamic> j) => UploadedDocument(
    id: j['id'] as String,
    key: j['key'] as String,
    url: j['url'] as String,
    contentType: (j['contentType'] ?? 'application/octet-stream') as String,
    size: (j['size'] is int)
        ? j['size'] as int
        : (j['size'] is String ? int.tryParse(j['size']) : null),
  );
}

/// Generate a new draftId to group uploads before driver creation
String newDraftId() => const Uuid().v4();


MediaType _mediaType(String contentType) {
  final parts = contentType.split('/');
  if (parts.length == 2) return MediaType(parts[0], parts[1]);
  return  MediaType('application', 'octet-stream');
}

String _guessContentType(String nameOrPath) {
  final ext = p.extension(nameOrPath).toLowerCase();
  switch (ext) {
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.png':
      return 'image/png';
    case '.gif':
      return 'image/gif';
    case '.mp4':
      return 'video/mp4';
    case '.pdf':
      return 'application/pdf';
    case '.txt':
      return 'text/plain';
    default:
      return 'application/octet-stream';
  }
}

/// Upload files and attach directly to an existing driver
Future<List<String>> uploadMultipleViaProxyForDriver({
  required String driverId,           // 👈 existing driver id
  String? folder,                     // e.g. 'drivers'
  List<String>? documentTypes,        // optional labels per file
}) async {
  final picked = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
  if (picked == null || picked.files.isEmpty) return [];

  final uploadedUrls = <String>[];

  for (var i = 0; i < picked.files.length; i++) {
    final f = picked.files[i];
    final docType = (documentTypes != null && i < documentTypes.length) ? documentTypes[i] : null;

    final req = http.MultipartRequest('POST', Uri.parse('$backendBase/documents/upload'));
    req.fields['driverId'] = driverId;      // 👈 attach on server
    if (folder != null && folder.isNotEmpty) req.fields['folder'] = folder;
    if (docType != null && docType.isNotEmpty) req.fields['documentType'] = docType;

    final bytes = f.bytes ?? await File(f.path!).readAsBytes();
    req.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: f.name,
      contentType: _mediaType(_guessContentType(f.name)),
    ));

    final streamed = await req.send();
    final respBody = await streamed.stream.bytesToString();
    if (streamed.statusCode != 201) {
      // ignore: avoid_print
      print('❌ Upload failed: ${streamed.statusCode} $respBody');
      continue;
    }

    final parsed = jsonDecode(respBody) as Map<String, dynamic>;
    final docJson = parsed['document'] as Map<String, dynamic>;
    final url = (docJson['url'] as String?) ?? '';
    if (url.isNotEmpty) uploadedUrls.add(url);
  }

  return uploadedUrls;
}


Future<List<String>> uploadMultipleViaProxy({
  String? folder,
  String? draftId,
  String? driverId,
  List<String>? documentTypes, // same length as picked files if used
}) async {
  final picked = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
  if (picked == null || picked.files.isEmpty) return [];

  final uploadedUrls = <String>[];

  for (var i = 0; i < picked.files.length; i++) {
    final f = picked.files[i];
    final docType = (documentTypes != null && i < documentTypes.length) ? documentTypes[i] : null;

    final req = http.MultipartRequest('POST', Uri.parse('$backendBase/documents/upload'));

    // Optional fields – only sent if provided
    if (folder != null && folder.isNotEmpty) req.fields['folder'] = folder;
    if (draftId != null && draftId.isNotEmpty) req.fields['draftId'] = draftId;
    if (driverId != null && driverId.isNotEmpty) req.fields['driverId'] = driverId;
    if (docType != null && docType.isNotEmpty) req.fields['documentType'] = docType;

    final bytes = f.bytes ?? await File(f.path!).readAsBytes();
    req.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: f.name,
      contentType: _mediaType(_guessContentType(f.name)),
    ));

    final streamed = await req.send();
    final respBody = await streamed.stream.bytesToString();
    if (streamed.statusCode != 201) {
      // ignore: avoid_print
      print('❌ Upload failed: ${streamed.statusCode} $respBody');
      continue;
    }

    final parsed = jsonDecode(respBody) as Map<String, dynamic>;
    final docJson = parsed['document'] as Map<String, dynamic>;
    final url = (docJson['url'] as String?) ?? '';
    if (url.isNotEmpty) uploadedUrls.add(url);
  }

  return uploadedUrls;
}

/// Upload one file with multipart/form-data to /documents/upload
Future<UploadedDocument> _uploadSingleFileViaProxy({
  required String fileName,
  required Uint8List bytes,
  required String contentType,
  String? folder,
  required String draftId,
  String? documentType,
}) async {
  final uri = Uri.parse('$backendBase/documents/upload');

  final req = http.MultipartRequest('POST', uri);

  // required to claim later
  req.fields['draftId'] = draftId;

  // optional helpers
  if (folder != null && folder.isNotEmpty) req.fields['folder'] = folder;
  if (documentType != null && documentType.isNotEmpty) {
    req.fields['documentType'] = documentType;
  }

  final filePart = http.MultipartFile.fromBytes(
    'file',
    bytes,
    filename: fileName,
    contentType: _mediaType(contentType),
  );
  req.files.add(filePart);

  final streamed = await req.send();
  final respBody = await streamed.stream.bytesToString();

  if (streamed.statusCode != 201) {
    throw Exception('Upload failed: ${streamed.statusCode} $respBody');
  }

  final parsed = jsonDecode(respBody) as Map<String, dynamic>;
  final docJson = (parsed['document'] as Map<String, dynamic>);
  return UploadedDocument.fromJson(docJson);
}

/// List documents (uses backend pagination and optional userId filter)
Future<List<Map<String, dynamic>>> listDocuments(
    {int page = 1, int pageSize = 20, String? userId}) async {
  final q = <String, String>{
    'page': '$page',
    'pageSize': '$pageSize',
    if (userId != null && userId.isNotEmpty) 'userId': userId,
  };
  final uri = Uri.parse('$backendBase/documents').replace(queryParameters: q);
  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('Failed to list: ${resp.statusCode} ${resp.body}');
  }

  final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
  final items = (parsed['items'] as List).cast<Map<String, dynamic>>();
  return items;
}

Uri getDocumentUrlFromItem(Map<String, dynamic> item) {
  final url = (item['url'] as String?) ?? '';
  if (url.isEmpty) throw Exception('Document item has no url');
  return Uri.parse(url);
}

Future<bool> deleteDocument(String docId) async {
  final resp = await http.delete(Uri.parse('$backendBase/documents/$docId'));
  return resp.statusCode == 204 || resp.statusCode == 200;
}




