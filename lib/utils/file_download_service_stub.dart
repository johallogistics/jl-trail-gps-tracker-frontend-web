// lib/utils/file_download_service_stub.dart
import '../models/shift_log_model.dart';

/// Stub declarations used for conditional imports.
/// Platform implementations must provide the same API signatures.

Future<void> downloadFileFromUrl(String url, {String? filename}) {
  // Fallback no-op for platforms where impl isn't provided.
  return Future.value();
}

Future<void> downloadCsv(String csvData, {String filename = 'export.csv'}) {
  return Future.value();
}

Future<String?> exportShiftLogsToCsvImpl(List<ShiftLog> logs, {String filename = 'export.csv'}) {
  // Fallback: do nothing and return null.
  return Future.value(null);
}
