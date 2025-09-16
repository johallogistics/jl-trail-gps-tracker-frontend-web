import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/views/admin/trial_report_management_screen.dart';
import '../../repositories/admin/dashboard_repository.dart';
import 'daily_report_screen.dart';
import 'driver_manageement_screen.dart';

class DashboardDataController extends GetxController {
  final driversCount = 0.obs;
  final formSubmissionsCount = 0.obs;
  final shiftLogsCount = 0.obs;
  final clientCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final response = await DashboardRepository.fetchStats();

      if (response != null) {
        driversCount.value = response['drivers'] ?? 0;
        formSubmissionsCount.value = response['form_submissions'] ?? 0;
        shiftLogsCount.value = response['shift_logs'] ?? 0;
      } else {
        print('Failed to load dashboard stats');
      }
    } catch (e) {
      print("Error fetching dashboard stats: $e");
    }
  }
}

class DashboardHomeScreen extends StatelessWidget {
  final DashboardDataController controller = Get.put(DashboardDataController());

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<IconData> _icons = [
    Icons.person,
    Icons.business,
    Icons.route,
    Icons.assignment,
  ];

  final List<String> _titles = [
    'Drivers',
    'Clients',
    'Trails',
    'Reports',
  ];

  final List<Widget> _screens = [
    DriverManagementScreen(),
    SizedBox(),
    TrailManagementScreen(),
    DailyReportManagement(),
  ];

  @override
  Widget build(BuildContext context) {
    controller.fetchStats();
    return Scaffold(
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: List.generate(4, (index) {
            int count = 0;
            switch (index) {
              case 0:
                count = controller.driversCount.value;
                break;
              case 1:
                count = controller.clientCount.value;
                break;
              case 2:
                count = controller.formSubmissionsCount.value;
                break;
              case 3:
                count = controller.shiftLogsCount.value;
                break;
            }

            return GestureDetector(
              onTap: () {
                if (_screens[index] is! SizedBox) {
                  Get.to(() => _screens[index]);
                } else {
                  print('No screen configured for ${_titles[index]}');
                }
              },
              child: _buildStatCard(
                _titles[index],
                count,
                _icons[index],
                _colors[index],
              ),
            );
          }),
        ),
      )),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
