import 'package:flutter/material.dart';
import 'package:get/get.dart';



class DashboardDataController extends GetxController {
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
    clientsCount.value = 1;
    trailsCount.value = 58;
    reportsCount.value = 40;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx (() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(_titles[0], controller.driversCount.value, _icons[0], _colors[0]),
            _buildStatCard(_titles[1], controller.clientsCount.value, _icons[1], _colors[1]),
            _buildStatCard(_titles[2], controller.trailsCount.value, _icons[2], _colors[2]),
            _buildStatCard(_titles[3], controller.reportsCount.value, _icons[3], _colors[3]),
          ],
        ),
      ),),
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
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
