// Only used for Flutter Web
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'dart:async';

import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../controllers/admin/driver_management_controller.dart';
import '../../controllers/admin/location_controller.dart';
import '../../models/admin/driver_model.dart';
import '../../utils/map_service_web.dart';

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

    registerMapViewFactory();
    driverController.fetchDrivers();

    Future.delayed(const Duration(seconds: 1), () async {
      await MapService.initializeMap(13.0827, 80.2707);
    });

    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      final driver = driverController.selectedDriver.value;
      if (driver != null) {
        _fetchDriverLocation(driver);
      }
    });
  }

  Future<void> _fetchDriverLocation(Driver driver) async {
    try {
      await locationController.fetchDriverLocation(driver.phone);
      final location = locationController.selectedLocation.value;
      if (location != null) {
        MapService.updateMap(location.latitude, location.longitude);
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text("Driver Live Location"),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Obx(() {
              if (driverController.drivers.isEmpty) {
                return const Center(child: Text("No drivers available"));
              }

              return DropdownButton<String>(
                isExpanded: true,
                value: driverController.selectedDriver.value?.id,
                hint: const Text("Select Driver"),
                items: driverController.drivers.map((driver) {
                  return DropdownMenuItem(
                    value: driver.id,
                    child: Text("${driver.name} - ${driver.phone}"),
                  );
                }).toList(),
                onChanged: (id) {
                  final driver = driverController.drivers.firstWhere((d) => d.id == id);
                  driverController.selectedDriver.value = driver;
                  _fetchDriverLocation(driver);
                },
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              final location = locationController.selectedLocation.value;
              if (location == null) {
                return const Center(child: Text("Select a driver to view location"));
              }

              MapService.updateMap(location.latitude, location.longitude);

              return const HtmlElementView(viewType: 'mapmyindia-map');
            }),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    MapService.destroyMap();
    super.dispose();
  }
}
