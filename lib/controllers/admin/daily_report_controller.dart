import 'dart:typed_data';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api/api_manager.dart';
import '../../models/shift_log_model.dart';
import '../../utils/file_download_service_b2.dart';


class ShiftLogRepository {

  final box = GetStorage();
  final String baseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app'; // Replace with your backend URL


  // Future<List<ShiftLog>> fetchShiftLogs() async {
  //   final response = await ApiManager.get('dailyReports');
  //   if (response.statusCode == 200) {
  //     String targetLanguage = box.read('selectedLanguage') ?? 'en'; // Get selected language
  //     List<dynamic> data = jsonDecode(response.body);
  //     // Translate each item in the list
  //     List<Map<String, dynamic>> translatedData = await Future.wait(
  //         data.map((json) async => await translateJson(json, targetLanguage))
  //     );
  //     return translatedData.map((json) => ShiftLog.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load shift logs');
  //   }
  // }

  Future<ShiftLogPage> fetchShiftLogs({
    int page = 1,
    int pageSize = 20,
    DateTime? start,
    DateTime? end,
    String? driver,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    String _fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    if (start != null) params['start'] = _fmt(start);
    if (end != null) params['end'] = _fmt(end);
    if (driver != null && driver.trim().isNotEmpty) {
      params['driver'] = driver.trim();
    }

    final uri = Uri(
      path: 'dailyReports',
      queryParameters: params.isEmpty ? null : params,
    );

    final response = await ApiManager.getUri(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load shift logs: ${response.statusCode} ${response.reasonPhrase}');
    }

    final decoded = jsonDecode(response.body);

    // New shape: { message: string, payload: { items: [...], page, pageSize, total, totalPages } }
    if (decoded is Map<String, dynamic>) {
      final payload = decoded['payload'];

      // New paging envelope
      if (payload is Map<String, dynamic> && payload['items'] is List) {
        final rawItems = (payload['items'] as List).cast<dynamic>();
        final items = rawItems
            .map((e) => ShiftLog.fromJson((e as Map).cast<String, dynamic>()))
            .toList();

        final p = (payload['page'] is num) ? (payload['page'] as num).toInt() : page;
        final ps = (payload['pageSize'] is num) ? (payload['pageSize'] as num).toInt() : pageSize;
        final total = (payload['total'] is num) ? (payload['total'] as num).toInt() : items.length;
        final totalPages = (payload['totalPages'] is num) ? (payload['totalPages'] as num).toInt()
            : (total == 0 ? 1 : ((total + ps - 1) ~/ ps));

        return ShiftLogPage(
          items: items,
          page: p,
          pageSize: ps,
          total: total,
          totalPages: totalPages,
        );
      }

      // Old shape you handled earlier: { payload: [ ... ] }
      if (payload is List) {
        final allItems = payload
            .map((e) => ShiftLog.fromJson((e as Map).cast<String, dynamic>()))
            .toList();

        final total = allItems.length;
        final ps = pageSize > 0 ? pageSize : (total == 0 ? 1 : total);
        final totalPages = total == 0 ? 1 : ((total + ps - 1) ~/ ps);
        final currentPage = page < 1 ? 1 : (page > totalPages ? totalPages : page);

        final startIndex = (currentPage - 1) * ps;
        final endIndex = (startIndex + ps > total) ? total : (startIndex + ps);
        final pageItems = (startIndex < total) ? allItems.sublist(startIndex, endIndex) : <ShiftLog>[];

        return ShiftLogPage(
          items: pageItems,
          page: currentPage,
          pageSize: ps,
          total: total,
          totalPages: totalPages,
        );
      }
    }

    // Backend returned a bare array
    if (decoded is List) {
      final allItems = decoded
          .map((e) => ShiftLog.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      final total = allItems.length;
      final ps = pageSize > 0 ? pageSize : (total == 0 ? 1 : total);
      final totalPages = total == 0 ? 1 : ((total + ps - 1) ~/ ps);
      final currentPage = page < 1 ? 1 : (page > totalPages ? totalPages : page);

      final startIndex = (currentPage - 1) * ps;
      final endIndex = (startIndex + ps > total) ? total : (startIndex + ps);
      final pageItems = (startIndex < total) ? allItems.sublist(startIndex, endIndex) : <ShiftLog>[];

      return ShiftLogPage(
        items: pageItems,
        page: currentPage,
        pageSize: ps,
        total: total,
        totalPages: totalPages,
      );
    }

    throw Exception('Unexpected response shape for /dailyReports');
  }



  Future<bool> postShiftLog(ShiftLog shiftLog) async {
    try {
      final response = await ApiManager.post('dailyReport', shiftLog.toJsonWithoutId());
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in postShiftLog: $e');
      return false;
    }
  }

  Future<bool> deleteMediaForShiftLog(int shiftLogId, String rawUrlOrKey) async {
    try {
      // Prefer to send the file key to server. If rawUrl contains query key param -> extract it
      String fileKey = rawUrlOrKey;
      try {
        final uri = Uri.parse(rawUrlOrKey);
        if (uri.queryParameters.containsKey('key')) {
          fileKey = uri.queryParameters['key']!;
        } else if (uri.pathSegments.isNotEmpty) {
          // maybe last segment is file name; you can adapt
          fileKey = uri.pathSegments.last;
        }
      } catch (_) {}

      // Example delete endpoint: DELETE /dailyReports/:id/media
      final resp = await ApiManager.delete('dailyReports/$shiftLogId/media', body: {'key': fileKey});
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        return true;
      } else {
        // optional: log resp.body
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<ShiftLogResponse?> fetchShiftLogById(String id) async {
    final response = await ApiManager.get('shifts/$id');
    if (response.statusCode == 200) {
      // String targetLanguage = box.read('selectedLanguage') ?? 'en';
      Map<String, dynamic> json =  jsonDecode(response.body);
      // Map<String, dynamic> translatedJson = await translateJson(json, targetLanguage);
      return ShiftLogResponse.fromJson(json);
    } else {
      return null;
    }
  }


  // Update Shift Log (PUT /dailyReports/:id)
  Future<bool> updateShiftLog(ShiftLog log) async {
    final response = await ApiManager.put('dailyReports/${log.id}', log.toJson());
    return response.statusCode == 200;
  }

  // Delete Shift Log (DELETE /dailyReports/:id)
  Future<bool> deleteShiftLog(int id) async {
    final storage = GetStorage();
    final token = storage.read('token');
    final url = Uri.parse('$baseUrl/dailyReports/$id');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> uploadFileToServer({
    required Uint8List bytes,
    required String filename,
    required String mimeType, // e.g. 'image/jpeg' or 'video/mp4' or 'application/pdf'
  }) async {
    final token = box.read('token') as String?;
    final uri = Uri.parse('$baseUrl/documents/upload'); // adjust if your endpoint differs

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    // Attach file. For web, use MultipartFile.fromBytes; for mobile it's okay too.
    final multipartFile = http.MultipartFile.fromBytes(
      'file', // field name expected by backend; change if different
      bytes,
      filename: filename,
      contentType: MediaTypeFromString(mimeType),
    );
    request.files.add(multipartFile);

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Upload failed: ${resp.statusCode} ${resp.body}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return json;
  }

  /// Helper to attach uploaded media (by key or url) to the shift log record
  /// Expects server endpoint POST /dailyReports/:id/media with body { "url": "...", "key": "..." }
// ShiftLogRepository (add or replace existing attach method)
  Future<bool> attachMediaToShiftLog(int shiftLogId, {
    required String url,
    String? key,
    String? documentId,
  }) async {
    // Normalized payload
    final body = <String, dynamic>{ 'url': url };
    if (key != null && key.isNotEmpty) body['key'] = key;
    if (documentId != null && documentId.isNotEmpty) body['documentId'] = documentId;
    try {
      // fetch current record
      final getResp = await ApiManager.get('dailyReports/$shiftLogId');
      if (getResp.statusCode == 200) {
        final decoded = jsonDecode(getResp.body);
        // normalize: find payload or document
        Map<String, dynamic>? payload;
        if (decoded is Map && decoded.containsKey('payload')) payload = decoded['payload'];
        // else if (decoded is Map && decoded.containsKey('document')) payload = decoded; // fallback
        else payload = decoded as Map<String, dynamic>?;

        final currentList = <String>[];
        if (payload != null) {
          final existing = payload['imageVideoUrls'] ?? payload['image_video_urls'] ?? payload['media'] ?? payload['documents'];
          if (existing is List) {
            for (var e in existing) currentList.add(e?.toString() ?? '');
          }
        }

        // avoid duplicates
        if (!currentList.contains(url)) currentList.add(url);

        final updateBody = {
          'imageVideoUrls': currentList,
        };

        final putResp = await ApiManager.put('dailyReports/$shiftLogId', updateBody);
        if (putResp.statusCode == 200) return true;
        print('attachMedia: PATCH dailyReports/$shiftLogId -> ${putResp.statusCode} ${putResp.body}');
      } else {
        print('attachMedia: GET dailyReports/$shiftLogId -> ${getResp.statusCode} ${getResp.body}');
      }
    } catch (e) {
      print('attachMedia (patch) exception: $e');
    }

    // all attempts failed
    return false;
  }

}

class ShiftLogPage {
  final List<ShiftLog> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  ShiftLogPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });
}