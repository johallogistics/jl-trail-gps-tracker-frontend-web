import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/driver_management_controller.dart';
import '../../utils/file_download_service_web.dart';
import 'driver/driver_add_screen.dart';
import 'driver/driver_edit_screen.dart';
import 'driver_live_location_screen.dart';

class DriverManagementScreen extends StatefulWidget {
  DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final DriverController driverController = Get.put(DriverController());

  @override
  void initState() {
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

  /// ✅ Driver List with Toggle Location Switch
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
              DataColumn(label: Text("Location Sharing")),
              DataColumn(label: Text("Download Files")),
              DataColumn(label: Text("Actions")),
            ],
            rows: drivers.map((driver) {
              return DataRow(cells: [
                DataCell(Text(driver.id ?? "N/A")),
                DataCell(Text(driver.name)),
                DataCell(Text(driver.phone.toString())),
                DataCell(Text(driver.employeeId)),
                DataCell(Text(driver.address)),

                /// ✅ Toggle Switch for Location Sharing
                DataCell(
                  Transform.scale(
                    scale: 0.7, // ✅ Makes the Switch smaller
                    child: Switch(
                      value: driver.locationEnabled ?? false,
                      onChanged: (value) =>
                          _toggleLocation(driver.phone, value),
                      activeColor:
                          Colors.blueAccent, // ✅ Switch color when enabled
                      inactiveThumbColor:
                          Colors.grey, // ✅ Thumb color when disabled
                      inactiveTrackColor:
                          Colors.grey[300], // ✅ Track color when disabled
                    ),
                  ),
                ),
                /// ✅ Download Files Button
                DataCell(
                  driver.proofDocs != null && driver.proofDocs.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.download, color: Colors.blue),
                          onPressed: () async {
                            for (final url in driver.proofDocs) {
                              await downloadFileFromUrl(
                                  url); // ⬅️ Your custom download logic
                            }
                          },
                        )
                      : Icon(Icons.insert_drive_file, color: Colors.grey),
                ),

                /// ✅ Edit & Delete Actions
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditPopup(driver),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          driverController.deleteDriver(driver.id!),
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

  // ElevatedButton(
  // onPressed: () async {
  // urls =  await uploadMultipleMediaAndSendUrls();
  // print(urls);
  // },
  // style: ElevatedButton.styleFrom(
  // backgroundColor: Colors.blueAccent,
  // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  // ),
  // child: Text('Upload Images and Videos', style: TextStyle(color: Colors.white)),
  // ),

  /// ✅ Toggle Location Sharing Service
  /// ✅ Toggle Location Sharing Service with Local Update
  Future<void> _toggleLocation(String phone, bool isEnabled) async {
    try {
      // Show loading indicator
      Get.snackbar(
        "Updating Location",
        "Please wait...",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );

      // ✅ Make API call
      final response = await driverController.toggleLocation(phone, isEnabled);

      if (response['success'] == true) {
        // ✅ Update the local state
        int index =
            driverController.drivers.indexWhere((d) => d.phone == phone);
        if (index != -1) {
          driverController.drivers[index].locationEnabled = isEnabled;
          driverController.drivers.refresh(); // 🔥 Trigger UI refresh
        }

        // ✅ Show success message
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
