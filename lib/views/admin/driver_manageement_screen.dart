import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'driver_live_location_screen.dart';
import '../../controllers/admin/admin_home_screen_controller.dart';

class DriverManagementScreen extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Driver Management"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Driver List"),
              Tab(text: "Live Location"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDriverList(),
            DriverLiveLocationScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        var drivers = controller.driversResponse.value.payload.drivers;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            columns: [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Phone")),
              DataColumn(label: Text("Employee ID")),
              DataColumn(label: Text("Address")),
              DataColumn(label: Text("Actions")),
            ],
            rows: drivers.map((driver) {
              return DataRow(cells: [
                DataCell(Text(driver.id)),
                DataCell(Text(driver.name)),
                DataCell(Text(driver.phone.toString())),
                DataCell(Text(driver.employeeId)),
                DataCell(Text(driver.address)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => controller.editDriver(driver.id),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteDriver(driver.id),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      }),
    );
  }
}
