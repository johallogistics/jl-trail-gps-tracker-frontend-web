import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui_web' as ui;
import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../utils/map_service.dart';
import 'dart:html' as html;

class DriverLiveLocationScreen extends StatefulWidget {
  const DriverLiveLocationScreen({super.key});

  @override
  State<DriverLiveLocationScreen> createState() => _DriverLiveLocationScreenState();
}

class _DriverLiveLocationScreenState extends State<DriverLiveLocationScreen> {
  final AdminController adminController = Get.find<AdminController>();

  final double lat = 13.0827;  // Default lat for Chennai
  final double lng = 80.2707;  // Default lng for Chennai

  @override
  void initState() {
    super.initState();

    // ✅ Register view factory for the map container
    ui.platformViewRegistry.registerViewFactory(
      'mapmyindia-map',
          (int viewId) {
        final div = html.DivElement()
          ..id = 'map-container'
          ..style.width = '100%'
          ..style.height = '100vh';
        return div;
      },
    );

    // ✅ Delay initialization to ensure the container is rendered
    Future.delayed(const Duration(seconds: 1), () async {
      print('⏳ Delaying map initialization...');
      await MapService.initializeMap(lat, lng);
    });
  }

  void _updateMap(double lat, double lng) {
    Future.delayed(const Duration(milliseconds: 500), () {
      MapService.updateMap(lat, lng);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Live Location")),
      body: Column(
        children: [
          // Dropdown to select driver
          Padding(
            padding: const EdgeInsets.all(10),
            child: Obx(() {
              return DropdownButton<String>(
                hint: const Text("Select Driver"),
                value: adminController.selectedDriverId.value.isNotEmpty
                    ? adminController.selectedDriverId.value
                    : null,
                items: adminController.driversResponse.value.payload.drivers
                    .map((driver) => DropdownMenuItem(
                  value: driver.id,
                  child: Text(driver.name),
                ))
                    .toList(),
                onChanged: (String? driverId) {
                  if (driverId != null) {
                    adminController.fetchDriverLocation(driverId);
                  }
                },
              );
            }),
          ),

          // Display the map
          Expanded(
            child: Obx(() {
              final selectedLocation = adminController.selectedDriverLocation.value;
              if (selectedLocation == null) {
                return const Center(child: Text("Select a driver to view location"));
              }

              // ✅ Update map with the selected driver's location
              _updateMap(selectedLocation.latitude, selectedLocation.longitude);

              return Container(
                width: double.infinity,
                height: double.infinity,
                child: HtmlElementView(viewType: 'mapmyindia-map'),
              );
            }),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    // ✅ Destroy the map when leaving the screen
    // MapService.destroyMap();
    super.dispose();
  }
}


