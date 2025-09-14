// lib/utils/file_download_service_web.dart
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:csv/csv.dart';

Future<void> downloadFileFromUrl(String url, {String? filename}) async {
  final req = await html.HttpRequest.request(url, responseType: 'arraybuffer');
  final buffer = req.response as ByteBuffer;
  final blob = html.Blob([buffer]);
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);

  final defaultName = Uri.parse(url).pathSegments.isNotEmpty
      ? Uri.parse(url).pathSegments.last
      : 'file';

  final anchor = html.AnchorElement(href: blobUrl)
    ..setAttribute('download', filename ?? defaultName)
    ..click();

  html.Url.revokeObjectUrl(blobUrl);
}


/// Trigger browser download of a CSV string.
Future<void> downloadCsv(String csvData, {String filename = 'export.csv'}) async {
  final bytes = utf8.encode(csvData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// Provide backward-compatible export function. On web this simply triggers download and returns null.
Future<void> exportShiftLogsToCsvImpl(dynamic  logs, {String filename = 'export.csv'}) async {
  // If caller gives us already-structured objects, convert to CSV.
  // Here we assume `logs` is a List<List<dynamic>> or List<Map> — caller can pass csv string instead.
  // For safety, if it's a string, treat it as csv content.
  String csv;
  if (logs is String) {
    csv = logs;
  } else {
    // if logs are List<List<dynamic>> already (rows), use ListToCsvConverter
    try {
      if (logs.isNotEmpty && logs[0] is List) {
        csv = const ListToCsvConverter().convert(List<List<dynamic>>.from(logs));
      } else {
        // If logs are objects (maps), try to flatten by keys of first item
        if (logs.isNotEmpty && logs[0] is Map) {
          final keys = (logs[0] as Map).keys.toList();
          final rows = <List<dynamic>>[keys];
          for (final m in logs) {
            rows.add(keys.map((k) => (m as Map)[k] ?? '').toList());
          }
          csv = const ListToCsvConverter().convert(rows);
        } else {
          // fallback: call toString() on each
          csv = logs.map((e) => e.toString()).join('\n');
        }
      }
    } catch (_) {
      csv = logs.map((e) => e.toString()).join('\n');
    }
  }

  await downloadCsv(csv, filename: filename);
  return null;
}
