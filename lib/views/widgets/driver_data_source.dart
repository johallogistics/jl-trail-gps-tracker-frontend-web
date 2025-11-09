import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/driver_management_controller.dart';

class DriverDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> drivers;
  final Future<int> Function(String driverId) getDocCount;
  final Future<void> Function(String phone, bool isEnabled) onToggleLocation;
  final void Function(dynamic driver) onEdit;
  final Future<void> Function(String driverId) onDownloadAll;

  final DriverController driverController = Get.put(DriverController());


  DriverDataSource({
    required this.context,
    required this.drivers,
    required this.getDocCount,
    required this.onToggleLocation,
    required this.onEdit,
    required this.onDownloadAll,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= drivers.length) return null;
    final driver = drivers[index];

    final String id = driver.id?.toString() ?? 'N/A';
    final String name = driver.name ?? '';
    final String phone = driver.phone?.toString() ?? '';
    final String empId = driver.employeeId ?? '';
    final String address = driver.address ?? '';

    // expiry info
    final daysLeft = driver.licenseDaysLeft;
    final isExpiringSoon = driver.isLicenseExpiringSoon;
    final isExpired = driver.isLicenseExpired;
    final expiryText = driver.formattedLicenseExpiry ?? '-';
    final expiryColor = isExpired
        ? Colors.red
        : isExpiringSoon
        ? Colors.orange
        : Colors.black;

    String? subText;
    if (daysLeft != null) {
      if (isExpired) {
        subText = 'Expired ${daysLeft.abs()} day${daysLeft.abs() == 1 ? '' : 's'} ago';
      } else if (isExpiringSoon) {
        subText = 'Expiring in $daysLeft day${daysLeft == 1 ? '' : 's'}';
      }
    }

    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(phone)),
        DataCell(Text(empId)),
        DataCell(Text(address)),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                expiryText,
                style: TextStyle(
                  color: expiryColor,
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
                      color: expiryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Location switch
        DataCell(
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: driver.locationEnabled ?? false,
              onChanged: (value) => onToggleLocation(phone, value),
              activeColor: Colors.blueAccent,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
        ),
        // Download – greyed out if docCount == 0
        DataCell(
          FutureBuilder<int>(
            future: getDocCount(driver.id?.toString() ?? ''),
            builder: (context, snap) {
              final loading = snap.connectionState == ConnectionState.waiting;
              final hasFiles = (snap.data ?? 0) > 0;

              if (loading) {
                return const SizedBox(
                  height: 24, width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              return IconButton(
                icon: Icon(Icons.download,
                    color: hasFiles ? Colors.blue : Colors.grey),
                onPressed: hasFiles
                    ? () async => onDownloadAll(driver.id!)
                    : null, // null disables & greys the button
                tooltip: hasFiles ? 'Download files' : 'No files',
              );
            },
          ),
        ),
        // Actions
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(driver),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => driverController.deleteDriver(driver.id!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => drivers.length;

  @override
  int get selectedRowCount => 0;
}
