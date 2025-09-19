// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:mappls_gl/mappls_gl.dart';
//
// class AdminMapScreen extends StatelessWidget {
//   final double lat;
//   final double lng;
//
//   AdminMapScreen({super.key, required this.lat, required this.lng});
//   late MapplsMapController _controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Driver Location')),
//       body: MapplsMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(lat, lng),
//           zoom: 14,
//         ),
//         onMapCreated: (MapplsMapController controller) async {
//           _controller = controller;
//
//           // Load image from assets as bytes
//           final ByteData byteData = await rootBundle.load("assets/marker_icon.png");
//           final Uint8List imageData = byteData.buffer.asUint8List();
//
//           // Add image to map style
//           await _controller.addImage("driver_marker", imageData);
//
//           // Now add the marker symbol
//           await _controller.addSymbol(
//             SymbolOptions(
//               geometry: LatLng(lat, lng),
//               iconImage: "driver_marker", // use registered name
//               iconSize: 1.5,
//               textField: "Driver Location",
//               textOffset: Offset(0, 2),
//               textSize: 12.0,
//             ),
//           );
//         }
//         ,
//       ),
//     );
//   }
// }
