import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../api/api_manager.dart';
import '../../controllers/admin/driver_management_controller.dart';
import '../../utils/file_download_service.dart'; // platform-safe downloader
import '../widgets/driver_docs_manager.dart';
import 'driver/driver_add_screen.dart';
import 'driver/driver_edit_screen.dart';

class DriverManagementScreen extends StatefulWidget {
  DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final DriverController driverController = Get.put(DriverController());

  // cache driverId -> docCount
  final Map<String, int> _docCountCache = {};

  Future<int> _getDocCount(String driverId) async {
    if (_docCountCache.containsKey(driverId)) {
      return _docCountCache[driverId]!;
    }
    final base = Uri.parse(ApiManager.baseUrl);
    final uri = base.replace(
      path: '${base.path}/documents',
      queryParameters: {
        'driverId': driverId,
        'page': '1',
        'pageSize': '1',
      },
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      _docCountCache[driverId] = 0;
      return 0;
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    final count = (parsed['count'] as num?)?.toInt() ?? 0;
    _docCountCache[driverId] = count;
    return count;
  }

  @override
  void initState() {
    driverController.fetchDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Driver Management"),
              ElevatedButton(
                onPressed: () {
                  Get.dialog(DriverAddPopup());
                },
                child: const Text("Add Driver"),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Driver List"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDriverList(),
          ],
        ),
      ),
    );
  }

  /// ✅ Driver List with Toggle Location Switch + Manage Docs
  Widget _buildDriverList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        final drivers = driverController.drivers;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              columns: const [
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Employee ID")),
                DataColumn(label: Text("Address")),
                DataColumn(label: Text("Driving License Expiry")),
                DataColumn(label: Text("Location Sharing")),
                DataColumn(label: Text("Documents")),
                DataColumn(label: Text("Actions")),
              ],
              rows: drivers.map((driver) {
                return DataRow(cells: [
                  DataCell(Text(driver.id?.toString() ?? "N/A")),
                  DataCell(Text(driver.name ?? '')),
                  DataCell(Text(driver.phone?.toString() ?? '')),
                  DataCell(Text(driver.employeeId ?? '')),
                  DataCell(Text(driver.address ?? '')),
                  DataCell(
                    Builder(
                      builder: (context) {
                        final daysLeft = driver.licenseDaysLeft;
                        final isExpiringSoon = driver.isLicenseExpiringSoon;
                        final isExpired = driver.isLicenseExpired;
                        final expiryText = driver.formattedLicenseExpiry ?? '-';

                        final color = isExpired
                            ? Colors.red
                            : isExpiringSoon
                            ? Colors.orange
                            : Colors.black;

                        String? subText;
                        if (daysLeft != null) {
                          if (isExpired) {
                            subText =
                            'Expired ${daysLeft.abs()} day${daysLeft.abs() == 1 ? '' : 's'} ago';
                          } else if (isExpiringSoon) {
                            subText =
                            'Expiring in $daysLeft day${daysLeft == 1 ? '' : 's'}';
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              expiryText,
                              style: TextStyle(
                                color: color,
                                fontWeight: (isExpired || isExpiringSoon)
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (subText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  subText,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Toggle Location
                  DataCell(
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: driver.locationEnabled ?? false,
                        onChanged: (value) =>
                            _toggleLocation(driver.phone ?? '', value),
                        activeColor: Colors.blueAccent,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  // Manage Documents (greyed if none)
                  DataCell(
                    FutureBuilder<int>(
                      future: _getDocCount(driver.id ?? ''),
                      builder: (context, snap) {
                        final loading =
                            snap.connectionState == ConnectionState.waiting;
                        final hasFiles = (snap.data ?? 0) > 0;

                        if (loading) {
                          return const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        return IconButton(
                          icon: Icon(Icons.folder_open,
                              color: hasFiles ? Colors.blue : Colors.grey),
                          tooltip: hasFiles
                              ? 'Manage Documents'
                              : 'No files',
                          onPressed: hasFiles
                              ? () {
                            final id = driver.id;
                            if (id == null || id.isEmpty) {
                              Get.snackbar('No ID', 'Driver ID not found',
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            openDocsManager(
                              id,
                              driver.name ?? 'Driver',
                              buildDownloadUrl: buildDownloadUrl,
                              downloadFileFromUrl: downloadFileFromUrl,
                            );
                          }
                              : null,
                        );
                      },
                    ),
                  ),
                  // Edit & Delete
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditPopup(driver),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            driverController.deleteDriver(driver.id!),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        );
      }),
    );
  }

  // ✅ Correct backend path here
  String buildDownloadUrl(
      String key, {
        String? filename,
        String disposition = 'inline',
      }) {
    final uri = Uri.https(
      'jl-trail-gps-tracker-backend-production.up.railway.app',
      '/files/download',
      {
        'key': key,
        if (filename != null && filename.isNotEmpty) 'filename': filename,
        'disposition': disposition, // 'inline' or 'attachment'
      },
    );
    return uri.toString();
  }

  /// If you still want your bulk download helper
  Future<void> _downloadDriverDocs(String driverId) async {
    try {
      Get.snackbar('Fetching', 'Getting documents...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(milliseconds: 800));

      final docs = await _fetchDriverDocuments(driverId);
      if (docs.isEmpty) {
        Get.snackbar('No Files', 'No documents found for this driver',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      int success = 0;
      for (final d in docs) {
        final key = (d['key'] as String?) ?? '';
        if (key.isEmpty) continue;

        final filename = (d['metadata']?['originalName'] as String?) ?? '';
        final url =
        buildDownloadUrl(key, filename: filename, disposition: 'attachment');

        try {
          await downloadFileFromUrl(url,
              filename: filename.isEmpty ? null : filename);
          success++;
        } catch (_) {}
      }

      Get.snackbar(
        'Download',
        'Downloaded $success of ${docs.length} file(s)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to download: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDriverDocuments(
      String driverId) async {
    final base = Uri.parse(ApiManager.baseUrl);
    final uri = base.replace(
      path: '${base.path}/documents',
      queryParameters: {
        'driverId': driverId,
        'page': '1',
        'pageSize': '100',
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('List failed: ${resp.statusCode} ${resp.body}');
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = (parsed['items'] as List).cast<Map<String, dynamic>>();
    return items;
  }

  Future<void> _toggleLocation(String phone, bool isEnabled) async {
    try {
      Get.snackbar(
        "Updating Location",
        "Please wait...",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );

      final response = await driverController.toggleLocation(phone, isEnabled);

      if (response['success'] == true) {
        final index =
        driverController.drivers.indexWhere((d) => d.phone == phone);
        if (index != -1) {
          driverController.drivers[index].locationEnabled = isEnabled;
          driverController.drivers.refresh();
        }

        Get.snackbar(
          "Success",
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Failed",
          response['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      Get.snackbar(
        "Error",
        "Failed to update location sharing",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      // ignore: avoid_print
      print("Error toggling location: $error");
    }
  }
}

void _showEditPopup(driver) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 400,
        child: EditDriverScreen(driver: driver),
      ),
    ),
  );
}
