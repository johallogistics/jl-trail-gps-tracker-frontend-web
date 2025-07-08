import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../models/consolidated_form_submission_model.dart';
import '../../utils/file_download_service_mobile.dart';
import '../consolidated_report_screen.dart';
import 'edit_trail_screen.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';

class VehicleManagementScreen extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());



  void exportTrailDataToCsv(List<FormSubmissionModel> trails) {
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

    final rows = [
      headers,
      ...trails.map((trail) {
        final hasVehicle = trail.vehicleDetails.isNotEmpty;
        final vehicle = hasVehicle ? trail.vehicleDetails[0] : null;

        return [
          trail.id?.toString() ?? "",
          trail.location,
          trail.date,
          trail.masterDriverName,
          trail.empCode,
          trail.mobileNo,
          trail.customerDriverName,
          trail.customerMobileNo,
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
      }).toList()
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final blob = html.Blob([utf8.encode(csvData)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "trail_data.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vehicle Management'),
            ElevatedButton(
              onPressed: () {
                exportTrailDataToCsv(controller.trailsResponse.value.payload);
              },
              child: Text("Export to CSV"),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          var trails = controller.trailsResponse.value.payload;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: [
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
                rows: controller.trailsResponse.value.payload.map((trail) {
                  final hasVehicle = trail.vehicleDetails.isNotEmpty;
                  final vehicle = hasVehicle ? trail.vehicleDetails[0] : null;

                  return DataRow(cells: [
                    DataCell(Text(trail.id.toString())),
                    DataCell(Text(trail.location)),
                    DataCell(Text(trail.date)),
                    DataCell(Text(trail.masterDriverName)),
                    DataCell(Text(trail.empCode)),
                    DataCell(Text(trail.mobileNo)),
                    DataCell(Text(trail.customerDriverName)),
                    DataCell(Text(trail.customerMobileNo)),
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
                  trail.imageVideoUrls.isEmpty
                  ? Icon(Icons.insert_drive_file, color: Colors.grey) // empty file symbol
                      : IconButton(
                        icon: Icon(Icons.download, color: Colors.blue),
                        onPressed: () async {
                          for (var url in trail.imageVideoUrls) {
                            await downloadFileFromUrl(url);
                          }
                        },
                      ),
                    ),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_note, color: Colors.green),
                          onPressed: () {
                            Get.to(() => EditTrailScreen(trail: trail));
                            // controller.viewTrail(trail);
                            // Get.dialog(PopUpWidget());
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 18),
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
          // Navigate to the Create Trail Screen
          // Get.to(() => CreateTrailScreen());
          Get.to(() => FormScreen());

        },
        child: Icon(Icons.add),
      ),
    );
  }
}
