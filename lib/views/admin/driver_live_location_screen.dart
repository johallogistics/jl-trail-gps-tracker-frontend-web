import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapmyindia_flutter/MapImage/src/MapmyIndiaStillmap.dart';
import '../../controllers/admin/admin_home_screen_controller.dart';

class DriverLiveLocationScreen extends StatefulWidget {
  @override
  State<DriverLiveLocationScreen> createState() => _DriverLiveLocationScreenState();
}

class _DriverLiveLocationScreenState extends State<DriverLiveLocationScreen> {
  final AdminController adminController = Get.find<AdminController>();
  late html.ImageElement mapImage;

  @override
  void initState() {
    super.initState();

    // Create an image element
    mapImage = html.ImageElement()
      ..style.width = "600px"
      ..style.height = "300px"
      ..style.objectFit = "cover"
      ..alt = "Driver Location";

    // Register WebView for displaying the image
    ui.platformViewRegistry.registerViewFactory(
      'mapmyindia-map',
          (int viewId) {
        final div = html.DivElement()
          ..style.display = 'flex'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'center'
          ..style.width = '100%'
          ..style.height = '100%'
          ..append(mapImage);
        return div;
      },
    );
  }

  void updateMapImage(double lat, double lng) {
    String mapImageUrl =
    MapMyIndiaStillMap("dffc6557266bf7fc552c9ed64a6a3e8f").getMapImage(lat, lng);
    mapImage.src = mapImageUrl; // Update image source dynamically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Driver Live Location")),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
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

            // Live Location Map
            Expanded(
              child: Obx(() {
                final selectedLocation = adminController.selectedDriverLocation.value;
                if (selectedLocation == null) {
                  return Center(child: Text("Select a driver to view location"));
                }

                // Update map image dynamically
                updateMapImage(selectedLocation.latitude, selectedLocation.longitude);

                return Container(
                  width: 600,
                  height: 300,
                  child: HtmlElementView(viewType: 'mapmyindia-map'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
