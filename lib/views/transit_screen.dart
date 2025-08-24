import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/transit_controller.dart';
import '../utils/location_services/location_picker_widget.dart';

class TransitScreen extends StatefulWidget {
  const TransitScreen({super.key});

  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> {
  LatLng? _startCoords;
  String? _startAddress;

  LatLng? _endCoords;
  String? _endAddress;

  final TransitController controller = Get.put(TransitController());

  void _pickStartLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          onLocationPicked: (LatLng pos, String address) {
            setState(() {
              _startCoords = pos;
              _startAddress = address;
            });
          },
        ),
      ),
    );
  }

  void _pickEndLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          onLocationPicked: (LatLng pos, String address) {
            setState(() {
              _endCoords = pos;
              _endAddress = address;
            });
          },
        ),
      ),
    );
  }

  void _saveTransit() async {
    if (_startCoords == null || _endCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end locations")),
      );
      return;
    }

    try {
      await controller.startTransit(
        startLat: _startCoords!.latitude,
        startLng: _startCoords!.longitude,
        startAddress: _startAddress ?? "",
        endLat: _endCoords!.latitude,
        endLng: _endCoords!.longitude,
        endAddress: _endAddress ?? "",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transit started successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transit Tracking")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: Text(_startAddress ?? "Pick Start Location"),
              subtitle: _startCoords != null
                  ? Text("${_startCoords!.latitude}, ${_startCoords!.longitude}")
                  : null,
              trailing: ElevatedButton(
                onPressed: _pickStartLocation,
                child: const Text("Select"),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(_endAddress ?? "Pick End Location"),
              subtitle: _endCoords != null
                  ? Text("${_endCoords!.latitude}, ${_endCoords!.longitude}")
                  : null,
              trailing: ElevatedButton(
                onPressed: _pickEndLocation,
                child: const Text("Select"),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _saveTransit,
              icon: const Icon(Icons.save),
              label: const Text("Save Transit"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
