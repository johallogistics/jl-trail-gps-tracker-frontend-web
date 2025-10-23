import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// pages
import 'package:trail_tracker/views/admin/sign_off_list_screen.dart';
import 'package:trail_tracker/views/new_trail_form/trial_form_stepper.dart';
import 'package:trail_tracker/views/admin/admin_login_screen.dart';
import 'package:trail_tracker/views/admin/daily_report_screen.dart';
import 'package:trail_tracker/views/admin/dashboard_home_screen.dart';
import 'package:trail_tracker/views/admin/driver_management_screen.dart';

// NEW: Live transit screen you created earlier
import 'package:trail_tracker/views/driver_live_transit_screen.dart';

import '../../controllers/shift_log_controller.dart';
import '../../utils/image_upload_service.dart';

class DashboardController extends GetxController {
  final driversCount = 0.obs;
  final clientsCount = 0.obs;
  final trailsCount = 0.obs;
  final reportsCount = 0.obs;

  var selectedIndex = 0.obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  void fetchDashboardStats() async {
    // TODO: Replace with real API calls later
    driversCount.value = 22;
    clientsCount.value = 15;
    trailsCount.value = 58;
    reportsCount.value = 40;
  }

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void logout() {
    storage.remove('token'); // Clear token or any session key
    Get.offAllNamed('/login');
  }

  // Navigate to full-screen Live Tracking screen
  void openLiveTracking() {
    Get.to(() => const DriverLiveTransitScreen());
  }
}

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final ShiftLogController shiftLogController = Get.put(ShiftLogController());

  final List<Widget Function()> pageBuilders = [
        () => DashboardHomeScreen(),
        () => DriverManagementScreen(),
        () => SignOffListScreen(),
        () => DailyReportManagement(),
  ];

  DashboardScreen({super.key}) {
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
                  padding: const EdgeInsets.all(10),
                  child: pageBuilders[controller.selectedIndex.value](),
                )),
              ),
            ],
          );
        },
      ),
      // On smaller screens, provide a drawer that includes Live Tracking
      drawer: MediaQuery.of(context).size.width <= 800 ? Drawer(child: _buildDrawerContent(context)) : null,
    );
  }

  // For large screens we show this persistent side panel
  Widget _buildPersistentDrawer() {
    return Container(
      width: 250,
      color: Colors.blue.shade100,
      child: _buildDrawerContent(null),
    );
  }

  // Drawer contents are extracted to reuse in both Drawer and persistent panel
  Widget _buildDrawerContent(BuildContext? maybeContext) {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Icon(Icons.admin_panel_settings, size: 50, color: Colors.blue),
        const SizedBox(height: 10),
        const Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        _drawerItem(Icons.dashboard, 'Dashboard', 0),
        _drawerItem(Icons.supervisor_account, 'Driver Management', 1),
        _drawerItem(Icons.local_shipping, 'Trails', 2),
        _drawerItem(Icons.description, 'Daily Reports', 3),

        // NEW: Live Tracking entry
        ListTile(
          leading: const Icon(Icons.my_location, color: Colors.blue),
          title: const Text('Live Tracking'),
          onTap: () {
            // Close drawer if in mobile drawer mode
            if (maybeContext != null) Navigator.of(maybeContext).pop();
            controller.openLiveTracking();
          },
        ),

        const Spacer(),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout'),
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
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return Obx(() => ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      selected: controller.selectedIndex.value == index,
      selectedTileColor: Colors.blue.shade200,
      onTap: () {
        controller.changePage(index);
        if (index == 3) {
          shiftLogController.fetchShiftLogs();
        }
      },
    ));
  }
}
