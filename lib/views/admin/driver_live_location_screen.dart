import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapmyindia_flutter/MapImage/src/MapmyIndiaStillmap.dart';

import '../../controllers/admin/admin_home_screen_controller.dart';

class DriverLiveLocationScreen extends StatelessWidget {
  final AdminController adminController = Get.find<AdminController>();

  // Generate Static Map URL
  static String getMapUrl(double lat, double lng) {
    const apiKey = "dffc6557266bf7fc552c9ed64a6a3e8f"; // Replace with your API Key
    return "https://apis.mappls.com/advancedmaps/api/$apiKey/staticmap?center=$lat,$lng&zoom=14&size=600x300";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Live Location")),
      body: Column(
        children: [
          // Dropdown for selecting a driver
          Padding(
            padding: EdgeInsets.all(10),
            child: Obx(() {
              return DropdownButton<String>(
                hint: Text("Select Driver"),
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

          // Live Location Map (Web Image Rendering)
          Expanded(
            child: Obx(() {
              final selectedLocation = adminController.selectedDriverLocation.value;

              if (selectedLocation == null) {
                return Center(child: Text("Select a driver to view location"));
              }

              // Update the static map URL
              String mapUrl = getMapUrl(
                  selectedLocation.latitude, selectedLocation.longitude);

              String mapImageUrl = MapMyIndiaStillMap("dffc6557266bf7fc552c9ed64a6a3e8f")
                  .getMapImage(
                13.0827,80.2707,
              );

              // Register WebView for HTML Image Rendering
              ui.platformViewRegistry.registerViewFactory(
                'mapmyindia-map',
                    (int viewId) {
                  final img = html.ImageElement()
                    ..src = mapUrl
                    ..style.width = "600px"
                    ..style.height = "300px"
                    ..alt = "Driver Location";

                  return img;
                },
              );

              return Container(
                width: 600,
                height: 300,
                child: HtmlElementView(viewType: 'mapmyindia-map'),
              );
            }),
          ),
        ],
      ),
    );
  }
}
