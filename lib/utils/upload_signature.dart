import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

Future<String?> uploadSignature(Uint8List bytes) async {
  final uri = Uri.parse('https://jl-trail-gps-tracker-backend-production.up.railway.app/upload-signature');
  final request = http.MultipartRequest('POST', uri);

  // Create multipart file from bytes
  final mimeType = lookupMimeType('', headerBytes: bytes) ?? 'image/png';
  final mimeParts = mimeType.split('/');
  final multipartFile = http.MultipartFile.fromBytes(
    'file',
    bytes,
    filename: 'sign_${DateTime.now().millisecondsSinceEpoch}.png',
    contentType: MediaType(mimeParts[0], mimeParts[1]),
  );

  request.files.add(multipartFile);

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return body['url'] as String?;
  } else {
    throw Exception('Upload failed: ${response.statusCode} ${response.body}');
  }
}
