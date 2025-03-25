import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';  // Static maps


class AdminMapScreen extends StatelessWidget {
  final double lat;
  final double lng;

  AdminMapScreen({super.key, required this.lat, required this.lng});
  late MapmyIndiaMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Location')),
      body: MapmyIndiaMap(
        initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 14),
        onMapCreated: (MapmyIndiaMapController controller) {
          _controller = controller;

          // Add marker using SymbolOptions
          _controller.addSymbol(
            SymbolOptions(
              geometry: LatLng(lat, lng),
              iconImage: 'assets/marker_icon.png', // Replace with your marker icon
              iconSize: 1.5,
              textField: 'Driver Location',
              textOffset: Offset(0,2),
              textSize: 12.0,
            ),
          );
        },
      ),
    );
  }
}
