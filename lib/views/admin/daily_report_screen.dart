// views/admin/daily_report_management.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/shift_log_controller.dart';
import '../../models/shift_log_model.dart';
import '../../utils/file_download_service.dart';
import '../daily_report_screen.dart';

class DailyReportManagement extends StatefulWidget {
  @override
  State<DailyReportManagement> createState() => _DailyReportManagementState();
}

class _DailyReportManagementState extends State<DailyReportManagement> {
  final ShiftLogController controller = Get.put(ShiftLogController());

  final TextEditingController _driverFilterCtrl = TextEditingController();

  @override
  void dispose() {
    _driverFilterCtrl.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '--';
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart = controller.startDate.value ?? DateTime(now.year, now.month, now.day);
    final initialEnd = controller.endDate.value ?? DateTime(now.year, now.month, now.day);
    final res = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (res != null) {
      controller.setDateRange(res.start, res.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            const Text('Daily Report Management'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.fetchShiftLogs(force: true),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {
                // Export current page items (or implement server export endpoint)
                exportShiftLogsToCsvImpl(controller.shiftLogs);
              },
              child: const Text('Export to CSV'),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Obx(() {
              return Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      'Date: ${_dateLabel(controller.startDate.value)} → ${_dateLabel(controller.endDate.value)}',
                    ),
                    onPressed: _pickDateRange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _driverFilterCtrl,
                      decoration: InputDecoration(
                        hintText: 'Filter by driver name / code / phone',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: controller.setDriverQuery, // press Enter to search
                      onChanged: (text) {
                        controller.setDriverQuery(text);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Text('Rows:'),
                      const SizedBox(width: 6),
                      Obx(() {
                        return DropdownButton<int>(
                          value: controller.pageSize.value,
                          items: const [10, 20, 50, 100]
                              .map((s) => DropdownMenuItem<int>(value: s, child: Text('$s')))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            controller.setPageSize(v);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      _driverFilterCtrl.clear();
                      controller.setDriverQuery('');
                      controller.setDateRange(null, null);
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                  ),
                ],
              );
            }),
          ),

          // Table
          Expanded(
            child: Obx(() {
              final logs = controller.shiftLogs;

              final verticalCtrl = ScrollController();
              final horizontalCtrl = ScrollController();

              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Scrollbar(
                          controller: verticalCtrl,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: verticalCtrl,
                            scrollDirection: Axis.vertical,
                            child: Scrollbar(
                              controller: horizontalCtrl,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: horizontalCtrl,
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('S.NO')),
                                    DataColumn(label: Text('DATE')),
                                    DataColumn(label: Text('REGION')),
                                    DataColumn(label: Text('EMP CODE')),
                                    DataColumn(label: Text('DRIVER NAME')),
                                    DataColumn(label: Text('Contact No.')),
                                    DataColumn(label: Text('Driver Status')),
                                    DataColumn(label: Text('Capitalized Vehicle/Customer Vehicle')),
                                    DataColumn(label: Text('Purpose of Trial')),
                                    DataColumn(label: Text('Reason, If Others')),
                                    DataColumn(label: Text('Date Of Sale')),
                                    DataColumn(label: Text('VECV reporting Person')),
                                    DataColumn(label: Text('Dealer Name')),
                                    DataColumn(label: Text('Customer Name')),
                                    DataColumn(label: Text('Customer Driver Name')),
                                    DataColumn(label: Text('Customer Driver No')),
                                    DataColumn(label: Text('Present location')),
                                    DataColumn(label: Text('Vehicle No')),
                                    DataColumn(label: Text('Chassis No')),
                                    DataColumn(label: Text('Vehicle Model')),
                                    DataColumn(label: Text('GVW')),
                                    DataColumn(label: Text('Payload')),
                                    DataColumn(label: Text('Previous KMPL')),
                                    DataColumn(label: Text('Trial KMPL')),
                                    DataColumn(label: Text('cluster KMPL')),
                                    DataColumn(label: Text('Vehicle Odometer - Start')),
                                    DataColumn(label: Text('Vehicle Odometer - End')),
                                    DataColumn(label: Text('Trial KMS')),
                                    DataColumn(label: Text('HighWay Sweet Spot %')),
                                    DataColumn(label: Text('Normal Road Sweet Spot %')),
                                    DataColumn(label: Text('Hills Road Sweet Spot %')),
                                    DataColumn(label: Text('Trial Allocation')),
                                    DataColumn(label: Text('Media')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: logs.map((log) {
                                    DateTime? dt;
                                    try {
                                      dt = log.date is DateTime
                                          ? (log.date as DateTime)
                                          : DateTime.tryParse(log.date?.toString() ?? '');
                                    } catch (_) {}
                                    final dateTxt = dt != null
                                        ? dt.toString().split('.').first
                                        : (log.date?.toString() ?? '-');

                                    return DataRow(cells: [
                                      DataCell(Text(log.id?.toString() ?? '')),
                                      DataCell(Text(dateTxt)),
                                      DataCell(Text(log.region ?? '-')),
                                      DataCell(Text(log.employeeCode)),
                                      DataCell(Text(log.employeeName)),
                                      DataCell(Text(log.employeePhoneNo)),
                                      DataCell(Text(log.driverStatus)),
                                      DataCell(Text(log.capitalizedVehicleOrCustomerVehicle)),
                                      DataCell(Text(log.purposeOfTrial)),
                                      DataCell(Text(log.reason)),
                                      DataCell(Text(log.dateOfSale)),
                                      DataCell(Text(log.vecvReportingPerson)),
                                      DataCell(Text(log.dealerName)),
                                      DataCell(Text(log.customerName)),
                                      DataCell(Text(log.customerDriverName)),
                                      DataCell(Text(log.customerDriverNo)),
                                      DataCell(Text(log.presentLocation)),
                                      DataCell(Text(log.vehicleNo)),
                                      DataCell(Text(log.chassisNo)),
                                      DataCell(Text(log.vehicleModel)),
                                      DataCell(Text(log.gvw.toString())),
                                      DataCell(Text(log.payload.toString())),
                                      DataCell(Text(log.previousKmpl.toString())),
                                      DataCell(Text(log.trialKMPL)),
                                      DataCell(Text(log.clusterKmpl.toString())),
                                      DataCell(Text(log.vehicleOdometerStartingReading)),
                                      DataCell(Text(log.vehicleOdometerEndingReading)),
                                      DataCell(Text(log.trialKMS)),
                                      DataCell(Text(log.highwaySweetSpotPercent.toString())),
                                      DataCell(Text(log.normalRoadSweetSpotPercent.toString())),
                                      DataCell(Text(log.hillsRoadSweetSpotPercent.toString())),
                                      DataCell(Text(log.trialAllocation)),
                                      DataCell(
                                        log.imageVideoUrls.isEmpty
                                            ? const Icon(Icons.insert_drive_file, color: Colors.grey)
                                            : IconButton(
                                          icon: const Icon(Icons.download, color: Colors.blue),
                                          onPressed: () async {
                                            for (var url in log.imageVideoUrls) {
                                              await downloadFileFromUrl(url);
                                            }
                                          },
                                        ),
                                      ),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _showAddShiftLogDialog(
                                              context,
                                              isEdit: true,
                                              existingLog: log,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _confirmDelete(context, log.id!),
                                          ),
                                        ],
                                      )),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Loading overlay
                        if (controller.isLoading.value)
                          Container(
                            color: Colors.white.withOpacity(.6),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),

                  // Pagination bar (server-side)
                  Obx(() {
                    final p = controller.page.value;
                    final sz = controller.pageSize.value;
                    final tot = controller.total.value;
                    final pages = controller.totalPages.value;
                    final from = tot == 0 ? 0 : ((p - 1) * sz + 1);
                    final to = tot == 0 ? 0 : math.min(p * sz, tot);

                    return Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          Text('Showing $from–$to of $tot'),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Previous page',
                            onPressed: p <= 1 ? null : controller.prevPage,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text('Page ${tot == 0 ? 0 : p} / ${tot == 0 ? 0 : pages}'),
                          IconButton(
                            tooltip: 'Next page',
                            onPressed: p >= pages ? null : controller.nextPage,
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddShiftLogDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteShiftLog(id);
              // controller.fetchShiftLogs(force: true); // controller already reloads after delete
              if (context.mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showAddShiftLogDialog(BuildContext context, {bool isEdit = false, ShiftLog? existingLog}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 780),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: DailyReportScreen(
              isEdit: isEdit,
              existingLog: existingLog,
            ),
          ),
        ),
      ),
    ).then((_) {
      // After closing the modal, refresh current page
      controller.fetchShiftLogs(force: true);
    });
  }
}
