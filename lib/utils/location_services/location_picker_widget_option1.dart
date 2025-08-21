import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class DriverLocationPicker extends StatefulWidget {
  const DriverLocationPicker({super.key});

  @override
  State<DriverLocationPicker> createState() => _DriverLocationPickerState();
}

class _DriverLocationPickerState extends State<DriverLocationPicker> {
  LatLng? startLocation;
  LatLng? endLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _setLiveLocationAsStart();
  }

  /// Get live location for start
  Future<void> _setLiveLocationAsStart() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      startLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(startLocation!, 15);
  }

  /// Pick location on map (start or end)
  void _pickLocation(LatLng tappedPoint, bool isStart) {
    setState(() {
      if (isStart) {
        startLocation = tappedPoint;
      } else {
        endLocation = tappedPoint;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Locations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                "start": startLocation,
                "end": endLocation,
              });
            },
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: startLocation ?? LatLng(20.5937, 78.9629), // India
              zoom: 5,
              onTap: (tapPosition, point) {
                // By default, set END location
                _pickLocation(point, false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),

              // Live location marker
              CurrentLocationLayer(),

              // Start marker
              if (startLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startLocation!,
                      width: 40,
                      height: 40,
                      builder: (BuildContext context) {
                        return const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        );
                      },
                    ),
                  ],
                ),

              // End marker
              if (endLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: endLocation!,
                      width: 40,
                      height: 40,
                      builder: (BuildContext context) {
                        return const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),

          // Search bar for End Location
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search end location...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (query) async {
                // TODO: call MapmyIndia / Google Places API
                // For now, just simulate a result
                LatLng searchedPoint = LatLng(13.0827, 80.2707); // Chennai
                setState(() {
                  endLocation = searchedPoint;
                  _mapController.move(endLocation!, 14);
                });
              },
            ),
          ),

          // Toggle between picking START or END
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Tap on map to set START location")));
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text("Set Start"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Tap on map to set END location")));
                  },
                  icon: const Icon(Icons.flag),
                  label: const Text("Set End"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
