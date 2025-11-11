import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../api/api_manager.dart';

class DriverDoc {
  final String id;
  final String key;
  final String? originalName;
  final String contentType;
  final int size;
  final DateTime createdAt;

  DriverDoc({
    required this.id,
    required this.key,
    required this.contentType,
    required this.size,
    required this.createdAt,
    this.originalName,
  });

  factory DriverDoc.fromJson(Map<String, dynamic> j) {
    return DriverDoc(
      id: j['id'] as String,
      key: j['key'] as String,
      contentType: j['contentType'] as String? ?? 'application/octet-stream',
      size: (j['size'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      originalName: (j['metadata']?['originalName'] as String?),
    );
  }
}

Future<List<DriverDoc>> _fetchDocs(
    String driverId, {
      int page = 1,
      int pageSize = 20,
    }) async {
  final base = Uri.parse(ApiManager.baseUrl);
  final uri = base.replace(
    path: '${base.path}/documents',
    queryParameters: {
      'driverId': driverId,
      'page': '$page',
      'pageSize': '$pageSize',
    },
  );

  final resp = await http.get(uri);
  if (resp.statusCode != 200) {
    throw Exception('List failed: ${resp.statusCode} ${resp.body}');
  }
  final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
  final items = (parsed['items'] as List).cast<Map<String, dynamic>>();
  return items.map((e) => DriverDoc.fromJson(e)).toList();
}

Future<void> _deleteDoc(String docId) async {
  final base = Uri.parse(ApiManager.baseUrl);
  final uri = base.replace(path: '${base.path}/documents/$docId');
  final resp = await http.delete(uri);
  if (resp.statusCode != 200 && resp.statusCode != 204) {
    throw Exception('Delete failed: ${resp.statusCode} ${resp.body}');
  }
}

Future<void> _renameDoc(String docId, String newName) async {
  // Adjust payload if your backend uses a different field than metadata.originalName
  final base = Uri.parse(ApiManager.baseUrl);
  final uri = base.replace(path: '${base.path}/documents/$docId');
  final body = jsonEncode({
    'metadata': {'originalName': newName},
  });
  final resp =
  await http.put(uri, headers: {'Content-Type': 'application/json'}, body: body);
  if (resp.statusCode != 200) {
    throw Exception('Rename failed: ${resp.statusCode} ${resp.body}');
  }
}

/// Call this from your parent screen.
/// We accept the two callbacks to avoid undefined identifiers inside this file.
void openDocsManager(
    String driverId,
    String title, {
      required String Function(String key, {String? filename, String disposition})
      buildDownloadUrl,
      required Future<void> Function(String url, {String? filename})
      downloadFileFromUrl,
    }) {
  Get.dialog(
    DriverDocsManagerDialog(
      driverId: driverId,
      title: '$title – Documents',
      buildDownloadUrl: buildDownloadUrl,
      fetchDocs: _fetchDocs,
      renameDoc: _renameDoc,
      deleteDoc: _deleteDoc,
      downloadFileFromUrl: downloadFileFromUrl,
    ),
    barrierDismissible: true,
  );
}

class DriverDocsManagerDialog extends StatefulWidget {
  final String driverId;
  final String title;
  final String Function(String key, {String? filename, String disposition})
  buildDownloadUrl;
  final Future<List<DriverDoc>> Function(String driverId,
      {int page, int pageSize}) fetchDocs;
  final Future<void> Function(String docId, String newName) renameDoc;
  final Future<void> Function(String docId) deleteDoc;
  final Future<void> Function(String url, {String? filename})
  downloadFileFromUrl;

  const DriverDocsManagerDialog({
    super.key,
    required this.driverId,
    required this.title,
    required this.buildDownloadUrl,
    required this.fetchDocs,
    required this.renameDoc,
    required this.deleteDoc,
    required this.downloadFileFromUrl,
  });

  @override
  State<DriverDocsManagerDialog> createState() =>
      _DriverDocsManagerDialogState();
}

class _DriverDocsManagerDialogState extends State<DriverDocsManagerDialog> {
  int _page = 1;
  final int _pageSize = 10;
  bool _loading = true;
  List<DriverDoc> _docs = [];
  int _total = 0; // if API returns "count", wire it here

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final docs = await widget.fetchDocs(widget.driverId,
          page: _page, pageSize: _pageSize);
      setState(() {
        _docs = docs;
        // If API returns "count", set _total = that value instead
        if (docs.length < _pageSize && _page == 1) _total = docs.length;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(DriverDoc d) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete file?'),
        content: Text(
            'Are you sure you want to delete "${d.originalName ?? d.key}"?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await widget.deleteDoc(d.id);
      Get.snackbar('Deleted', d.originalName ?? d.key,
          snackPosition: SnackPosition.BOTTOM);
      _load();
    }
  }

  Future<void> _promptRename(DriverDoc d) async {
    final controller = TextEditingController(text: d.originalName ?? '');
    final newName = await Get.dialog<String?>(
      AlertDialog(
        title: const Text('Rename file'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'File name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: null),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Get.back(result: controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty && newName != d.originalName) {
      await widget.renameDoc(d.id, newName);
      Get.snackbar('Renamed', newName,
          snackPosition: SnackPosition.BOTTOM);
      _load();
    }
  }

  void _preview(DriverDoc d) {
    final url = widget.buildDownloadUrl(
      d.key,
      filename: d.originalName,
      disposition: 'inline',
    );

    Get.dialog(
      Dialog(
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 900,
          height: 600,
          child: d.contentType.startsWith('image/')
              ? InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          )
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(d.originalName ?? d.key,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const Divider(height: 1),
              const Expanded(
                child: Center(
                  child: Text(
                    'Preview opens in new tab for non-images.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close')),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _download(DriverDoc d) async {
    final url = widget.buildDownloadUrl(
      d.key,
      filename: d.originalName,
      disposition: 'attachment',
    );
    await widget.downloadFileFromUrl(url, filename: d.originalName);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 1000,
        height: 650,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _docs.isEmpty
                  ? const Center(child: Text('No documents found'))
                  : Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('File name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Size')),
                        DataColumn(label: Text('Created')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _docs.map((d) {
                        return DataRow(
                          cells: [
                            DataCell(Text(d.originalName ?? d.key)),
                            DataCell(Text(d.contentType)),
                            DataCell(Text(_formatSize(d.size))),
                            DataCell(Text('${d.createdAt}')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Preview',
                                    icon:
                                    const Icon(Icons.visibility),
                                    onPressed: () => _preview(d),
                                  ),
                                  IconButton(
                                    tooltip: 'Download',
                                    icon:
                                    const Icon(Icons.download),
                                    onPressed: () => _download(d),
                                  ),
                                  IconButton(
                                    tooltip: 'Rename',
                                    icon: const Icon(Icons
                                        .drive_file_rename_outline),
                                    onPressed: () =>
                                        _promptRename(d),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _confirmDelete(d),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Footer / pagination (client-side)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Text('Page $_page'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _page > 1
                        ? () {
                      setState(() => _page--);
                      _load();
                    }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Prev'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _docs.length == _pageSize
                        ? () {
                      setState(() => _page++);
                      _load();
                    }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
