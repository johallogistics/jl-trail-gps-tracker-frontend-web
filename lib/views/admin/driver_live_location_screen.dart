import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui_web' as ui;
import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../controllers/admin/location_controller.dart';
import '../../models/admin/locations_model.dart';
import '../../utils/map_service.dart';
import 'dart:html' as html;

// ✅ Register view factory only once globally
bool isViewFactoryRegistered = false;
void registerMapViewFactory() {
  if (!isViewFactoryRegistered) {
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
    isViewFactoryRegistered = true;
  }
}

class DriverLiveLocationScreen extends StatefulWidget {
  const DriverLiveLocationScreen({super.key});

  @override
  State<DriverLiveLocationScreen> createState() =>
      _DriverLiveLocationScreenState();
}

class _DriverLiveLocationScreenState extends State<DriverLiveLocationScreen> {
  final AdminController adminController = Get.find<AdminController>();
  final LocationController controller = Get.put(LocationController());

  final double lat = 13.0827; // Default lat for Chennai
  final double lng = 80.2707; // Default lng for Chennai

  @override
  void initState() {
    super.initState();

    // ✅ Register view factory globally
    registerMapViewFactory();

    controller.fetchLocations();

    // ✅ Delay initialization to ensure the container is rendered
    Future.delayed(const Duration(seconds: 1), () async {
      print('⏳ Initializing map...');
      await MapService.initializeMap(lat, lng);
    });
  }

  void _updateMap(double lat, double lng) {
    if (lat != 0.0 && lng != 0.0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        MapService.updateMap(lat, lng);
      });
    }
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
              if (controller.locations.isEmpty) {
                return const Center(
                  child: Text("No drivers available"),
                );
              }

              return DropdownButton<Location>(
                isExpanded: true,
                hint: const Text("Select Driver ID"),
                value: controller.selectedLocation.value,
                items: controller.locations.map((location) {
                  return DropdownMenuItem<Location>(
                    value: location,
                    child: Text("${location.phone} - ${location.driverId}"),
                  );
                }).toList(),
                onChanged: (Location? newValue) {
                  if (newValue != null) {
                    print("PHONE: ${newValue.phone}");
                    controller.selectedLocation.value = newValue;

                    // ✅ Update map when driver is selected
                    adminController.setDriverLocation(
                        newValue.latitude, newValue.longitude);
                    _updateMap(newValue.latitude, newValue.longitude);
                  }
                },
              );
            }),
          ),

          // Display the map
          Expanded(
            child: Obx(() {
              final selectedLocation =
                  adminController.selectedDriverLocation.value;

              if (selectedLocation == null) {
                return const Center(
                    child: Text("Select a driver to view location"));
              }

              // ✅ Update map with the selected driver's location
              _updateMap(
                  selectedLocation.latitude, selectedLocation.longitude);

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
    MapService.destroyMap();
    super.dispose();
  }
}
