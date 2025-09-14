// lib/utils/file_download_service.dart
// Conditional import pattern + wrapper functions so callers can always call
// `downloadCsv`, `downloadFileFromUrl`, `exportShiftLogsToCsvImpl` etc.

import 'file_download_service_stub.dart'
if (dart.library.html) 'file_download_service_web.dart'
if (dart.library.io) 'file_download_service_mobile.dart' as impl;

/// Download a file from a remote URL.
/// On web this triggers browser download; on mobile it saves to app documents dir.
Future<void> downloadFileFromUrl(String url, {String? filename}) {
  return impl.downloadFileFromUrl(url, filename: filename);
}

/// Download/generate a CSV string as a file.
/// `csvData` should be the CSV content (already converted).
Future<void> downloadCsv(String csvData, {String filename = 'export.csv'}) {
  return impl.downloadCsv(csvData, filename: filename);
}

/// Export a list of items as CSV using the platform implementation.
/// Returns a platform-dependent result:
/// - On mobile returns `String` path of saved file (or null)
/// - On web returns `void` (download triggered)
/// Wrapper returns `Future<String?>` (path or null).
Future<String?> exportShiftLogsToCsvImpl(List<dynamic> logs, {String filename = 'export.csv'}) async {
  final result = impl.exportShiftLogsToCsvImpl(logs, filename: filename);
  // impl may return Future<void>, Future<String>, or void.
  if (result is Future) {
    final awaited = await result;
    if (awaited is String) return awaited;
    return null;
  } else {
    // synchronous return (unlikely) — if String return it
    if (result is String) return result;
    return null;
  }
}
