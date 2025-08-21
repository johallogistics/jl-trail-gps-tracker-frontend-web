import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class LocationPicker extends StatefulWidget {
  final Function(LatLng, String) onLocationPicked; // callback with coords + address
  const LocationPicker({super.key, required this.onLocationPicked});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final MapController _mapController = MapController();
  LatLng _pickedLocation = LatLng(13.0827, 80.2707); // Default: Chennai
  String _pickedAddress = "Move map or search to pick location";
  TextEditingController _searchController = TextEditingController();

  // Fetch place results from Nominatim
  Future<List<Map<String, dynamic>>> _searchPlaces(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5";
    final response = await http.get(Uri.parse(url), headers: {
      "User-Agent": "flutter_map_location_picker" // Required by Nominatim
    });
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  void _moveToLocation(double lat, double lon, String displayName) {
    final newPos = LatLng(lat, lon);
    setState(() {
      _pickedLocation = newPos;
      _pickedAddress = displayName;
    });
    _mapController.move(newPos, 15);
    widget.onLocationPicked(newPos, displayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Location")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _pickedLocation,
              zoom: 13,
              onTap: (tapPos, point) {
                setState(() {
                  _pickedLocation = point;
                  _pickedAddress = "Pinned location: ${point.latitude}, ${point.longitude}";
                });
                widget.onLocationPicked(point, _pickedAddress);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 50,
                    height: 50,
                    builder: (context) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Card(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search place...",
                      contentPadding: const EdgeInsets.all(10),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          final results = await _searchPlaces(_searchController.text);
                          if (results.isNotEmpty) {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final place = results[index];
                                  return ListTile(
                                    title: Text(place["display_name"]),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _moveToLocation(
                                        double.parse(place["lat"]),
                                        double.parse(place["lon"]),
                                        place["display_name"],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _pickedAddress,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          widget.onLocationPicked(_pickedLocation, _pickedAddress);
          Navigator.pop(context);
        },
      ),
    );
  }
}
