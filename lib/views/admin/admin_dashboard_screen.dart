import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trail_tracker/views/admin/sign_off_list_screen.dart';

import '../../utils/image_upload_service.dart';
import '../new_trail_form/trial_form_stepper.dart';
import 'admin_login_screen.dart';
import 'daily_report_screen.dart';
import 'dashboard_home_screen.dart';
import 'driver_manageement_screen.dart';

class DashboardController extends GetxController {
  final driversCount = 0.obs;
  final clientsCount = 0.obs;
  final trailsCount = 0.obs;
  final reportsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  void fetchDashboardStats() async {
    // Simulate API calls (replace with your own repository calls)
    // await Future.delayed(Duration(milliseconds: 300));
    driversCount.value = 22;
    clientsCount.value = 15;
    trailsCount.value = 58;
    reportsCount.value = 40;
  }
  var selectedIndex = 0.obs;
  final storage = GetStorage();

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void logout() {
    storage.remove('token'); // Clear token or any session key
    Get.offAllNamed('/login');
  }
}

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  final List<Widget Function()> pageBuilders = [
        () => DashboardHomeScreen(),
        () => DriverManagementScreen(),
        () => SignOffListScreen(),
        () => DailyReportManagement(),
  ];

  DashboardScreen({super.key}) {
    // Read argument for default page index if passed
    final int? initialIndex = Get.arguments;
    if (initialIndex != null) {
      controller.selectedIndex.value = initialIndex;
    }
  }
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
                  child: pageBuilders[controller.selectedIndex.value](),
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
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout'),
            onTap: () {
              Get.defaultDialog(
                title: "Confirm Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Yes",
                textCancel: "Cancel",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back(); // Close dialog
                  controller.logout();
                },
              );
            },          ),
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
