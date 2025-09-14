// lib/utils/file_download_service_mobile.dart
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

/// Save remote file to app documents folder (mobile).
Future<void> downloadFileFromUrl(String url, {String? filename}) async {
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Failed to download: ${res.statusCode}');
  final bytes = res.bodyBytes;
  final dir = await getApplicationDocumentsDirectory();
  final name = filename ?? (Uri.parse(url).pathSegments.isNotEmpty ? Uri.parse(url).pathSegments.last : 'file');
  final file = File(p.join(dir.path, name));
  await file.writeAsBytes(bytes);
}

/// Save CSV to app documents directory. Returns saved path.
Future<String> downloadCsv(String csvData, {String filename = 'export.csv'}) async {
  final bytes = utf8.encode(csvData);
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, filename));
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Export logs to CSV and return the saved file path.
/// `logs` can be:
/// - A CSV string (String) -> saved directly
/// - A List<List<dynamic>> -> converted with ListToCsvConverter
/// - A List<Map> -> keys from first map used as headers
Future<String> exportShiftLogsToCsvImpl(dynamic  logs, {String filename = 'export.csv'}) async {
  String csv;
  if (logs is String) {
    csv = logs;
  } else {
    try {
      if (logs.isNotEmpty && logs[0] is List) {
        csv = const ListToCsvConverter().convert(List<List<dynamic>>.from(logs));
      } else if (logs.isNotEmpty && logs[0] is Map) {
        final keys = (logs[0] as Map).keys.toList();
        final rows = <List<dynamic>>[keys];
        for (final m in logs) {
          rows.add(keys.map((k) => (m as Map)[k] ?? '').toList());
        }
        csv = const ListToCsvConverter().convert(rows);
      } else {
        csv = logs.map((e) => e.toString()).join('\n');
      }
    } catch (_) {
      csv = logs.map((e) => e.toString()).join('\n');
    }
  }

  final path = await downloadCsv(csv, filename: filename);
  return path;
}
