import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/driver_management_controller.dart';
import 'driver/driver_add_screen.dart';
import 'driver/driver_edit_screen.dart';
import 'driver_live_location_screen.dart';
import '../../controllers/admin/admin_home_screen_controller.dart';

class DriverManagementScreen extends StatefulWidget {

  DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final DriverController driverController = Get.put(DriverController());

  @override
  void initState() {
    // TODO: implement initState
    driverController.fetchDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Driver Management"),
              ElevatedButton(
                onPressed: () {
                  Get.dialog(DriverAddPopup());
                },
                child: const Text("Add Driver"),
              ),
            ],
          ),
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
        var drivers = driverController.drivers;
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
                DataCell(Text(driver.id ?? "N/A")),
                DataCell(Text(driver.name)),
                DataCell(Text(driver.phone.toString())),
                DataCell(Text(driver.employeeId)),
                DataCell(Text(driver.address)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditPopup(driver),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => driverController.deleteDriver(driver.id!),
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

/// Show Edit Screen as a Popup Dialog
void _showEditPopup(driver) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 400, // Adjust as needed
        child: EditDriverScreen(driver: driver),
      ),
    ),
  );
}
