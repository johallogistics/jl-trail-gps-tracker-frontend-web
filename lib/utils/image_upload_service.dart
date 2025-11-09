import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../api/api_manager.dart';

const String backendBase = ApiManager.baseUrl;

class PresignResult {
  final String id;
  final String key;
  final String putUrl;
  final String publicUrl;
  PresignResult({required this.id, required this.key, required this.putUrl, required this.publicUrl});
  factory PresignResult.fromJson(Map<String, dynamic> j) =>
      PresignResult(id: j['id'], key: j['key'], putUrl: j['putUrl'], publicUrl: j['publicUrl']);
}

Future<List<String>> uploadMultipleToBackblaze() async {
  final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);

  if (result == null || result.files.isEmpty) {
    print('❌ No files selected');
    return [];
  }

  // 1) Ask backend for presigned URLs
  final filesPayload = result.files.map((f) => {
    'fileName': f.name,
    'contentType': f.bytes != null ? _guessContentType(f.name) : _guessContentType(f.path ?? f.name),
    'size': f.size,
  }).toList();

  final presignResp = await http.post(
    Uri.parse('$backendBase/documents/presign'),
    headers: {'Content-Type': 'application/json'},
    body: '{"files": ${_toJson(filesPayload)}, "userId": "abc123"}', // include your auth userId or remove
  );

  if (presignResp.statusCode != 200) {
    print('❌ Presign failed: ${presignResp.body}');
    return [];
  }

  final parsed = _parseJson(presignResp.body) as Map<String, dynamic>;
  final List<dynamic> results = (parsed['results'] as List<dynamic>);

  final presigned = results.map((e) => PresignResult.fromJson(e)).toList();

  // 2) PUT each file bytes directly to Backblaze S3
  final uploaded = <String>[];
  for (int i = 0; i < result.files.length; i++) {
    final f = result.files[i];
    final target = presigned[i];

    Uint8List bytes = f.bytes ?? await File(f.path!).readAsBytes();
    final contentType = _guessContentType(f.name);

    final put = await http.put(
      Uri.parse(target.putUrl),
      headers: {
        'Content-Type': contentType,
        'Content-Length': bytes.length.toString(),
      },
      body: bytes,
    );

    if (put.statusCode == 200) {
      print('✅ Uploaded: ${target.publicUrl}');
      uploaded.add(target.publicUrl);

      // 3) (Optional) confirm to backend so it updates size/contentType
      await http.post(Uri.parse('$backendBase/documents/${target.id}/confirm'));
    } else {
      print('❌ Upload failed for ${f.name}: ${put.statusCode} - ${put.body}');
    }
  }

  return uploaded;
}

// Helpers (keep minimal, no extra packages)
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
    default:
      return 'application/octet-stream';
  }
}

// tiny JSON utils to avoid bringing dart:convert usage here explicitly:
String _toJson(Object o) => _jsonEncoder.convert(o);
dynamic _parseJson(String s) => _jsonDecoder.convert(s);
final _jsonEncoder = JsonEncoder();
final _jsonDecoder = JsonDecoder();


Future<List<Map<String, dynamic>>> listDocuments({int page = 1, int pageSize = 20}) async {
  final resp = await http.get(Uri.parse('$backendBase/documents?page=$page&pageSize=$pageSize&userId=abc123'));
  if (resp.statusCode != 200) throw Exception('Failed to list: ${resp.body}');
  final parsed = _parseJson(resp.body) as Map<String, dynamic>;
  final items = (parsed['items'] as List).cast<Map<String, dynamic>>();
  return items;
}

Future<Uri> getDownloadUrl(String docId) async {
  final resp = await http.get(Uri.parse('$backendBase/documents/$docId/download'));
  if (resp.statusCode != 200) throw Exception('Failed: ${resp.body}');
  final parsed = _parseJson(resp.body) as Map<String, dynamic>;
  return Uri.parse(parsed['downloadUrl'] as String);
}

Future<bool> deleteDocument(String docId) async {
  final resp = await http.delete(Uri.parse('$backendBase/documents/$docId'));
  return resp.statusCode == 200;
}