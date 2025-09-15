// lib/utils/file_download_service.dart
// Conditional import pattern: pick correct platform impl.
import 'file_download_service_stub.dart'
if (dart.library.html) 'file_download_service_web.dart'
if (dart.library.io) 'file_download_service_mobile.dart' as impl;

import '../models/shift_log_model.dart';

/// Download a file from a remote URL.
/// On web this triggers browser download; on mobile it saves to app documents dir.
Future<void> downloadFileFromUrl(String url, {String? filename}) {
  return impl.downloadFileFromUrl(url, filename: filename);
}

/// Download/generate a CSV string as a file.
Future<void> downloadCsv(String csvData, {String filename = 'export.csv'}) {
  return impl.downloadCsv(csvData, filename: filename);
}

/// Export a list of ShiftLog as CSV using the platform implementation.
/// Returns the saved file path on mobile, or null on web (download triggered).
Future<String?> exportShiftLogsToCsvImpl(List<ShiftLog> logs, {String filename = 'export.csv'}) {
  return impl.exportShiftLogsToCsvImpl(logs, filename: filename);
}
