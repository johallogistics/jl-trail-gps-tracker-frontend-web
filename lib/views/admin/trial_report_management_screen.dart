import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/admin_home_screen_controller.dart';
import '../consolidated_report_screen.dart';
import '../create_trail_screen.dart';
import '../review_consolidated_report_screen.dart';
import '../widgets/pop_up_widget.dart';

class VehicleManagementScreen extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Management"),
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
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_note, color: Colors.green),
                          onPressed: () {
                            controller.viewTrail(trail);
                            Get.dialog(PopUpWidget());
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
