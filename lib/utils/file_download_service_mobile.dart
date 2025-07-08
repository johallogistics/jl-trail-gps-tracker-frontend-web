import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/shift_log_model.dart';

Future<void> downloadFileFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory(); // Or getExternalStorageDirectory()
      final fileName = p.basename(url);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      print("✅ Downloaded to ${file.path}");
    } else {
      print("❌ Failed to download: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error downloading file on mobile: $e");
  }
}

void exportShiftLogsToCsvImpl(List<ShiftLog> logs) {
  if (kDebugMode) {
    print("📱 CSV export is not yet supported on mobile.");
  }
}