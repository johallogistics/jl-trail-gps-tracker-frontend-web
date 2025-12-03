// utils/file_download_service.dart
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../api/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http_parser/http_parser.dart';

String getFullMediaUrl(String rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return '';
  rawUrl = rawUrl.trim();

  // If already absolute
  if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;

  // If it starts with a slash -> relative to server
  if (rawUrl.startsWith('/')) {
    final base = ApiConfig.baseUrl?.trim() ?? '';
    // Ensure no double-slash problems
    if (base.endsWith('/')) {
      return '$base${rawUrl.substring(1)}';
    } else {
      return '$base$rawUrl';
    }
  }

  // If it's a bare download query: "api/files/download?key=..."
  if (rawUrl.startsWith('/') || rawUrl.startsWith('files/') || rawUrl.contains('files/download')) {
    final base = ApiConfig.baseUrl?.trim() ?? '';
    if (base.endsWith('/')) {
      return '$base$rawUrl'.replaceAll('//files', '/files'); // safety
    } else {
      return '$base/$rawUrl';
    }
  }

  // If looks like an encoded key only (e.g., "daily-reports%2F2025%2F...") -> build download endpoint
  if (!rawUrl.contains('/') && rawUrl.contains('%2F')) {
    final base = ApiConfig.baseUrl?.trim() ?? '';
    final prefix = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$prefix/files/download?key=$rawUrl';
  }

  // fallback: try to prepend base
  final base = ApiConfig.baseUrl?.trim() ?? '';
  if (base.isEmpty) return rawUrl;
  return base.endsWith('/') ? '$base$rawUrl' : '$base/$rawUrl';
}

/// Download / open file. Behavior:
/// - Web: open in new tab (recommended)
/// - Mobile/Desktop: fetch bytes and save to temporary dir + open (requires path_provider & open_file)
Future<void> downloadFileFromUrl(String rawUrl) async {
  final url = getFullMediaUrl(rawUrl);
  if (url.isEmpty) return;

  // For web: open new tab/window (works for viewing & download depending on server headers)
  if (kIsWeb) {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    }
    return;
  }

  // For non-web (mobile/desktop): try to open the url first via launcher; if that fails, fetch and save.
  final uri = Uri.parse(url);
  try {
    if (await canLaunchUrl(uri)) {
      // prefer launcher (lets system or browser handle)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (e) {
    // ignore and fallback to manual fetch
  }

  // Manual fetch + save
  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    throw Exception('Failed to download file (${resp.statusCode})');
  }

  // Determine filename: try to read from headers, else from uri path
  String filename = '';
  final contentDisposition = resp.headers['content-disposition'];
  if (contentDisposition != null) {
    final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
    if (match != null) filename = match.group(1) ?? '';
  }
  if (filename.isEmpty) {
    filename = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'downloaded_file';
  }

  // Save to temp dir
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(resp.bodyBytes);

  // Try to open file
  await OpenFile.open(file.path);
}

MediaType MediaTypeFromString(String mime) {
  try {
    final parts = mime.split('/');
    if (parts.length == 2) return MediaType(parts[0], parts[1]);
  } catch (_) {}
  return MediaType('application', 'octet-stream');
}
