import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';

import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../models/consolidated_form_submission_model.dart';
import '../../utils/file_download_service.dart';
import '../consolidated_report_screen.dart';
import 'edit_trail_screen.dart';

class TrailManagementScreen extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  TrailManagementScreen({super.key});

  /// Build CSV and hand off to platform-appropriate download/save helper.
  Future<void> exportTrailDataToCsv(List<FormSubmissionModel> trails) async {
    final headers = [
      "Trail Id",
      "Location",
      "Date",
      "Master Driver",
      "Emp Code",
      "Mobile No",
      "Customer Driver",
      "Customer Mobile No",
      "Reg No",
      "Model",
      "Brand",
      "Start Odo",
      "End Odo",
      "Start Place",
      "End Place",
      "Fuel Consumed",
      "Trip Start Date",
      "Trip Finish Date"
    ];

    final rows = <List<dynamic>>[
      headers,
      ...trails.map((trail) {
        final hasVehicle = (trail.vehicleDetails ?? []).isNotEmpty;
        final vehicle = hasVehicle ? trail.vehicleDetails![0] : null;

        return [
          trail.id?.toString() ?? "",
          trail.location ?? "",
          trail.date ?? "",
          trail.masterDriverName ?? "",
          trail.empCode ?? "",
          trail.mobileNo ?? "",
          trail.customerDriverName ?? "",
          trail.customerMobileNo ?? "",
          vehicle?.vehicleRegNo.text ?? "NA",
          vehicle?.vehicleModel.text ?? "NA",
          vehicle?.brand.text ?? "NA",
          vehicle?.startOdo.text ?? "NA",
          vehicle?.endOdo.text ?? "NA",
          vehicle?.startPlace.text ?? "NA",
          vehicle?.endPlace.text ?? "NA",
          vehicle?.fuelConsumed.text ?? "NA",
          vehicle?.tripStartDate.text ?? "NA",
          vehicle?.tripFinishDate.text ?? "NA",
        ];
      }),
    ];

    final csvData = const ListToCsvConverter().convert(rows);

    // Use platform-safe helper from utils/file_download_service.dart
    // make sure your file_download_service.dart exposes `downloadCsv`
    await downloadCsv(csvData, filename: 'trail_data.csv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Vehicle Management'),
            ElevatedButton(
              onPressed: () {
                final payload = controller.trailsResponse.value.payload ?? <FormSubmissionModel>[];
                exportTrailDataToCsv(payload);
              },
              child: const Text("Export to CSV"),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final trails = controller.trailsResponse.value.payload ?? <FormSubmissionModel>[];
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Text("Trail Id")),
                  DataColumn(label: Text("Location")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Master Driver")),
                  DataColumn(label: Text("Emp Code")),
                  DataColumn(label: Text("Mobile No")),
                  DataColumn(label: Text("Customer Driver")),
                  DataColumn(label: Text("Customer Mobile No")),
                  DataColumn(label: Text("Reg No")),
                  DataColumn(label: Text("Model")),
                  DataColumn(label: Text("Brand")),
                  DataColumn(label: Text("Start Odo")),
                  DataColumn(label: Text("End Odo")),
                  DataColumn(label: Text("Start Place")),
                  DataColumn(label: Text("End Place")),
                  DataColumn(label: Text("Fuel Consumed")),
                  DataColumn(label: Text("Trip Start Date")),
                  DataColumn(label: Text("Trip Finish Date")),
                  DataColumn(label: Text("Media")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: trails.map((trail) {
                  final hasVehicle = (trail.vehicleDetails ?? []).isNotEmpty;
                  final vehicle = hasVehicle ? trail.vehicleDetails![0] : null;

                  return DataRow(cells: [
                    DataCell(Text(trail.id?.toString() ?? '')),
                    DataCell(Text(trail.location ?? '')),
                    DataCell(Text(trail.date ?? '')),
                    DataCell(Text(trail.masterDriverName ?? '')),
                    DataCell(Text(trail.empCode ?? '')),
                    DataCell(Text(trail.mobileNo ?? '')),
                    DataCell(Text(trail.customerDriverName ?? '')),
                    DataCell(Text(trail.customerMobileNo ?? '')),
                    DataCell(Text(vehicle?.vehicleRegNo.text ?? "NA")),
                    DataCell(Text(vehicle?.vehicleModel.text ?? "NA")),
                    DataCell(Text(vehicle?.brand.text ?? "NA")),
                    DataCell(Text(vehicle?.startOdo.text ?? "NA")),
                    DataCell(Text(vehicle?.endOdo.text ?? "NA")),
                    DataCell(Text(vehicle?.startPlace.text ?? "NA")),
                    DataCell(Text(vehicle?.endPlace.text ?? "NA")),
                    DataCell(Text(vehicle?.fuelConsumed.text ?? "NA")),
                    DataCell(Text(vehicle?.tripStartDate.text ?? "NA")),
                    DataCell(Text(vehicle?.tripFinishDate.text ?? "NA")),
                    DataCell(
                      trail.imageVideoUrls == null || trail.imageVideoUrls!.isEmpty
                          ? const Icon(Icons.insert_drive_file, color: Colors.grey)
                          : IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () async {
                          for (var url in trail.imageVideoUrls!) {
                            await downloadFileFromUrl(url);
                          }
                        },
                      ),
                    ),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.green),
                          onPressed: () {
                            Get.to(() => EditTrailScreen(trail: trail));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () => controller.deleteTrail(trail.id!),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => FormScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
