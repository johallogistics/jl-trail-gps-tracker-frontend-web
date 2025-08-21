import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'location_picker_widget.dart';


class TripLocationForm extends StatefulWidget {
  const TripLocationForm({super.key});

  @override
  State<TripLocationForm> createState() => _TripLocationFormState();
}

class _TripLocationFormState extends State<TripLocationForm> {
  LatLng? _startCoords;
  String? _startAddress;

  LatLng? _endCoords;
  String? _endAddress;

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

  void _saveTrip() {
    if (_startCoords == null || _endCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both locations")),
      );
      return;
    }

    // Example: Record to SQL/MySQL
    final tripRecord = {
      "start_lat": _startCoords!.latitude,
      "start_lon": _startCoords!.longitude,
      "start_address": _startAddress,
      "end_lat": _endCoords!.latitude,
      "end_lon": _endCoords!.longitude,
      "end_address": _endAddress,
    };

    // TODO: Send to your backend API (Fastify/SQL)
    print("Trip saved: $tripRecord");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Trip saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Location Picker")),
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
              onPressed: _saveTrip,
              icon: const Icon(Icons.save),
              label: const Text("Save Trip"),
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
