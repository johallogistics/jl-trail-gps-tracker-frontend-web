import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui_web' as ui;
import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../controllers/admin/driver_management_controller.dart';
import '../../controllers/admin/location_controller.dart';
import '../../models/admin/driver_model.dart';
import '../../models/admin/locations_model.dart';
import '../../utils/map_service.dart';
import 'dart:html' as html;
import 'dart:async';

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
  State<DriverLiveLocationScreen> createState() => _DriverLiveLocationScreenState();
}

class _DriverLiveLocationScreenState extends State<DriverLiveLocationScreen> {
  final AdminController adminController = Get.find<AdminController>();
  final DriverController driverController = Get.put(DriverController());
  final LocationController locationController = Get.put(LocationController());

  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();

    // ✅ Register view factory globally
    registerMapViewFactory();

    driverController.fetchDrivers();

    // ✅ Delay initialization to ensure the container is rendered
    Future.delayed(const Duration(seconds: 1), () async {
      print('⏳ Initializing map...');
      await MapService.initializeMap(13.0827, 80.2707); // Default location (Chennai)
    });

    // ✅ Timer to fetch driver location every 2 minutes
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (driverController.selectedDriver.value != null) {
        _fetchDriverLocation(driverController.selectedDriver.value!);
      }
    });
  }

  // ✅ Fetch driver location every 2 minutes
  Future<void> _fetchDriverLocation(Driver driver) async {
    print("📡 Fetching location for driver: ${driver.phone}");

    try {
      await locationController.fetchDriverLocation(driver.phone);

      final selectedLocation = locationController.selectedLocation.value;

      if (selectedLocation != null) {
        print("✅ Updated Location: ${selectedLocation.latitude}, ${selectedLocation.longitude}");
        MapService.updateMap(selectedLocation.latitude, selectedLocation.longitude);
      }
    } catch (error) {
      print("❌ Error fetching driver location: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Live Location")),
      body: Column(
        children: [
          // ✅ Dropdown to select driver
          Padding(
            padding: const EdgeInsets.all(10),
            child: Obx(() {
              if (driverController.drivers.isEmpty) {
                return const Center(child: Text("No drivers available"));
              }

              return DropdownButton<Driver>(
                isExpanded: true,
                hint: const Text("Select Driver"),
                value: driverController.selectedDriver.value,
                items: driverController.drivers.map((driver) {
                  return DropdownMenuItem<Driver>(
                    value: driver,
                    child: Text("${driver.name} - ${driver.phone}"),
                  );
                }).toList(),
                onChanged: (Driver? newValue) {
                  if (newValue != null) {
                    driverController.selectedDriver.value = newValue;

                    // ✅ Fetch location immediately when driver is selected
                    _fetchDriverLocation(newValue);
                  }
                },
              );
            }),
          ),

          // ✅ Map view
          Expanded(
            child: Obx(() {
              final selectedLocation = locationController.selectedLocation.value;

              if (selectedLocation == null) {
                return const Center(child: Text("Select a driver to view location"));
              }

              // ✅ Update map with the selected driver's location
              MapService.updateMap(
                selectedLocation.latitude,
                selectedLocation.longitude,
              );

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
    // ✅ Destroy the map and cancel the timer when leaving the screen
    MapService.destroyMap();
    _locationTimer?.cancel();
    super.dispose();
  }
}
