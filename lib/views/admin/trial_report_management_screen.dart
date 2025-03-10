import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/admin_home_screen_controller.dart';
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
          var trails = controller.trailsResponse.value.payload.trails;
          return SingleChildScrollView(
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
              rows: controller.trailsResponse.value.payload.trails.map((trail) {
                return DataRow(cells: [
                  DataCell(Text(trail.id)),
                  DataCell(Text(trail.location)),
                  DataCell(Text(trail.date)),
                  DataCell(Text(trail.masterDriverName)),
                  DataCell(Text(trail.empCode)),
                  DataCell(Text(trail.mobileNo)),
                  DataCell(Text(trail.customerDriverName)),
                  DataCell(Text(trail.customerMobileNo)),
                  DataCell(Text(trail.vehicleRegNo)),
                  DataCell(Text(trail.vehicleModel)),
                  DataCell(Text(trail.brand)),
                  DataCell(Text(trail.startOdo)),
                  DataCell(Text(trail.endOdo)),
                  DataCell(Text(trail.startPlace)),
                  DataCell(Text(trail.endPlace)),
                  DataCell(Text(trail.fuelConsumed)),
                  DataCell(Text(trail.tripStartDate)),
                  DataCell(Text(trail.tripFinishDate)),
                  DataCell(Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.edit_note,
                              color: Colors.green), // 👁 Eye Icon
                          onPressed: () {
                            controller.viewTrail(trail);
                            Get.dialog(PopUpWidget());
                          }),
                      // IconButton(
                      //   icon: Icon(Icons.edit, color: Colors.blue),
                      //   onPressed: () => controller.editTrail(trail.id),
                      // ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 18,),
                        onPressed: () => controller.deleteTrail(trail.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        }),
      ),
    );
  }
}
