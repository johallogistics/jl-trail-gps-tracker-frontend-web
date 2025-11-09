// lib/screens/driver_management_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../api/api_manager.dart';
import '../../controllers/admin/driver_management_controller.dart';
import '../../utils/file_download_service.dart'; // platform-safe downloader
import 'driver/driver_add_screen.dart';
import 'driver/driver_edit_screen.dart';
// import 'driver_live_location_screen.dart'; // if you enable later

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
    // Call /documents with tiny pageSize just to read "count"
    final uri = Uri.parse(ApiManager.baseUrl).replace(
      path: '${Uri.parse(ApiManager.baseUrl).path}/documents',
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
              // Tab(text: "Live Location"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDriverList(),
            // const DriverLiveLocationScreen(),
          ],
        ),
      ),
    );
  }

  /// ✅ Driver List with Toggle Location Switch + Download Files
  Widget _buildDriverList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        var drivers = driverController.drivers;

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
                DataColumn(label: Text("Download Files")),
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
                  /// ✅ Toggle Switch for Location Sharing
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
                  /// ✅ Download Files (from documents table)
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () async {
                        final id = driver.id;
                        if (id == null || id.isEmpty) {
                          Get.snackbar('No ID', 'Driver ID not found',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        await _downloadDriverDocs(id);
                      },
                    ),
                  ),
                  /// ✅ Edit & Delete
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditPopup(driver),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => driverController.deleteDriver(driver.id!),
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

  String buildDownloadUrl(String key, {String? filename, String disposition = 'inline'}) {
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


  /// ✅ Fetch docs for a driver and download each file (uses /documents?driverId=...)
  Future<void> _downloadDriverDocs(String driverId) async {
    try {
      Get.snackbar('Fetching', 'Getting documents...',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 800));

      final docs = await _fetchDriverDocuments(driverId);
      if (docs.isEmpty) {
        Get.snackbar('No Files', 'No documents found for this driver',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Option A: Download all immediately
      int success = 0;
      for (final d in docs) {
        final key = (d['key'] as String?) ?? '';
        if (key.isEmpty) continue;

        final filename = (d['metadata']?['originalName'] as String?) ?? '';
        final url = buildDownloadUrl(key, filename: filename, disposition: 'attachment');

        try {
          // EITHER: open in new tab (lets backend 302 to signed URL)
          // openDownload(url);

          // OR: actually download bytes and save (needs CORS headers exposed)
          await downloadFileFromUrl(url, filename: filename.isEmpty ? null : filename);
          success++;
        } catch (_) {
          // continue
        }
      }

      Get.snackbar(
        'Download',
        'Downloaded $success of ${docs.length} file(s)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Option B (if you prefer): show a dialog with a list of files and let user pick
      // await _showDocsDialog(docs);
    } catch (e) {
      Get.snackbar('Error', 'Failed to download: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  /// Calls GET {baseUrl}/documents?driverId=<id>&page=1&pageSize=100
  Future<List<Map<String, dynamic>>> _fetchDriverDocuments(String driverId) async {
    final uri = Uri.parse(ApiManager.baseUrl)
        .replace(path: '${Uri.parse(ApiManager.baseUrl).path}/documents', queryParameters: {
      'driverId': driverId,
      'page': '1',
      'pageSize': '100',
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('List failed: ${resp.statusCode} ${resp.body}');
    }
    final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = (parsed['items'] as List).cast<Map<String, dynamic>>();
    return items;
  }

  /// ✅ Toggle Location Sharing with Local Update
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

/// ✅ Show Edit Screen as a Popup Dialog
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
