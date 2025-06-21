import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

final supabase = Supabase.instance.client;

Future<List<String>> uploadMultipleMediaAndSendUrls() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.media, // supports both images and videos
  );

  if (result == null || result.files.isEmpty) {
    print('❌ No files selected');
    return [];
  }

  List<String> uploadedUrls = [];

  for (final file in result.files) {
    final fileBytes = file.bytes ?? await File(file.path!).readAsBytes();
    final extension = file.extension ?? 'bin';
    final fileName = 'media_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    try {
      final response = await supabase.storage
          .from('jl-digi-content') // your Supabase bucket name
          .uploadBinary('uploads/$fileName', fileBytes);

      final publicUrl = supabase.storage
          .from('jl-digi-content')
          .getPublicUrl('uploads/$fileName');

      print('✅ Uploaded: $publicUrl');
      uploadedUrls.add(publicUrl);
    } catch (e) {
      print('❌ Upload failed for ${file.name}: $e');
    }
  }

  if (uploadedUrls.isNotEmpty) {
    return uploadedUrls;
    // await sendUrlsToBackend(uploadedUrls);
  }
  return [];
}

Future<void> sendUrlsToBackend(List<String> mediaUrls) async {
  final response = await http.post(
    Uri.parse('https://your-backend.com/store-media-urls'),
    headers: {'Content-Type': 'application/json'},
    body: '{"userId": "abc123", "mediaUrls": ${mediaUrls.map((e) => '"$e"').toList()}}',
  );

  if (response.statusCode == 200) {
    print('✅ URLs sent to backend');
  } else {
    print('❌ Failed to send URLs: ${response.body}');
  }
}
