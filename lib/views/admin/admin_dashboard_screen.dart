import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/views/admin/trial_report_management_screen.dart';

import '../../utils/image_upload_service.dart';
import 'daily_report_screen.dart';
import 'driver_manageement_screen.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }
}

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  final List<Widget> pages = [
    Center(child: Text('Dashboard Home', style: TextStyle(fontSize: 24))),
    DriverManagementScreen(), // Driver Management with Live Location Tab
    VehicleManagementScreen(),
    DailyReportManagement(),
    // Center(child: Text('Users Management', style: TextStyle(fontSize: 24))),
    // Center(child: Text('Settings', style: TextStyle(fontSize: 24))),
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 800;
          return Row(
            children: [
              if (isLargeScreen) _buildPersistentDrawer(),
              Expanded(
                child: Obx(() => Container(
                  padding: EdgeInsets.all(10),
                  child: pages[controller.selectedIndex.value],
                )),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersistentDrawer() {
    return Container(
      width: 250,
      color: Colors.blue.shade100,
      child: Column(
        children: [
          SizedBox(height: 50),
          Icon(Icons.admin_panel_settings, size: 50, color: Colors.blue),
          SizedBox(height: 10),
          Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Divider(),
          _drawerItem(Icons.dashboard, 'Dashboard', 0),
          _drawerItem(Icons.supervisor_account, 'Driver Management', 1),
          _drawerItem(Icons.local_shipping, 'Trails', 2),
          _drawerItem(Icons.description, 'Daily Reports', 3),
          // _drawerItem(Icons.people, 'Clients', 4),
          // _drawerItem(Icons.settings, 'Settings', 5),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return Obx(() => ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      selected: controller.selectedIndex.value == index,
      selectedTileColor: Colors.blue.shade200,
      onTap: () => controller.changePage(index),
    ));
  }
}
