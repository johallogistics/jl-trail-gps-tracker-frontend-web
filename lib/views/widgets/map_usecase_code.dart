import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

const String backendUrl = "https://jl-trail-gps-tracker-backend-production.up.railway.app/api/driver-locations";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    if (position.speed > 1.0) {
      await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'driverId': inputData?['driverId'],
          'latitude': position.latitude,
          'longitude': position.longitude,
          'isIdle': false,
        }),
      );
    } else {
      await http.post(
        Uri.parse("$backendUrl/idle"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'driverId': inputData?['driverId'], 'isIdle': true}),
      );
    }

    return Future.value(true);
  });
}

// // admin code
// Future<void> fetchLocations() async {
//   final response = await http.get(Uri.parse("$backendUrl?isIdle=false"));
//   if (response.statusCode == 200) {
//     setState(() {
//       driverLocations = jsonDecode(response.body);
//     });
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mapmyindia_gl/mapmyindia_gl.dart';
//
// const String backendUrl = "https://your-backend.com/api/locations";
// const String mapmyIndiaAccessToken = "your-mapmyindia-access-token";
//
// class AdminMapScreen extends StatefulWidget {
//   @override
//   _AdminMapScreenState createState() => _AdminMapScreenState();
// }
//
// class _AdminMapScreenState extends State<AdminMapScreen> {
//   MapmyIndiaMapController? mapController;
//   List<dynamic> driverLocations = [];
//
//   Future<void> fetchLocations() async {
//     final response = await http.get(Uri.parse(backendUrl));
//     if (response.statusCode == 200) {
//       setState(() {
//         driverLocations = jsonDecode(response.body);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     MapmyIndiaAccountManager.setMapSDKKey(mapmyIndiaAccessToken);
//     fetchLocations();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Live Driver Locations")),
//       body: MapmyIndiaMap(
//         onMapCreated: (controller) {
//           mapController = controller;
//           fetchLocations();
//         },
//         initialCameraPosition: CameraPosition(
//           target: LatLng(28.6139, 77.2090), // Default to Delhi
//           zoom: 10,
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await fetchLocations();
//           if (mapController != null) {
//             for (var loc in driverLocations) {
//               mapController!.addSymbol(SymbolOptions(
//                 geometry: LatLng(loc['latitude'], loc['longitude']),
//                 iconImage: "marker-15",
//               ));
//             }
//           }
//         },
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
// }
