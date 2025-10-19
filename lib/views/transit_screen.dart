// transit_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // <— Google Maps LatLng
import '../controllers/transit_controller.dart';
import '../utils/location_services/location_picker_widget.dart'; // (updated file below)

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

  String? _ongoingTransitId;

  final TransitController controller = Get.put(TransitController());

  @override
  void initState() {
    super.initState();
    _loadOngoingTransit();
  }

  void _loadOngoingTransit() async {
    final transit = await controller.getOngoingTransit();
    if (transit != null) {
      setState(() {
        _ongoingTransitId = transit["id"].toString();
        _startCoords = LatLng(
          (transit["startLatitude"] as num).toDouble(),
          (transit["startLongitude"] as num).toDouble(),
        );
        _startAddress = transit["startAddress"] ?? "From saved location";
        _endCoords = LatLng(
          (transit["endLatitude"] as num).toDouble(),
          (transit["endLongitude"] as num).toDouble(),
        );
        _endAddress = transit["endAddress"] ?? "To saved location";
      });

      controller.currentTransitId.value = transit["id"].toString();
    }
  }

  Future<void> _pickStartLocation() async {
    if (_ongoingTransitId != null) return;
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          initial: _startCoords,
          hint: "Search start location...",
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _startCoords = result['latLng'] as LatLng;
        _startAddress = result['address'] as String;
      });
    }
  }

  Future<void> _pickEndLocation() async {
    if (_ongoingTransitId != null) return;
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          initial: _endCoords,
          hint: "Search destination...",
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _endCoords = result['latLng'] as LatLng;
        _endAddress = result['address'] as String;
      });
    }
  }

  Future<void> _saveTransit() async {
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

      _loadOngoingTransit();
    } catch (e) {
      debugPrint("Error:::::::::::::::::::::::::::::: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _completeTransit() async {
    if (controller.currentTransitId.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No ongoing transit to complete")),
      );
      return;
    }

    try {
      await controller.completeTransit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transit completed successfully")),
      );

      setState(() {
        _ongoingTransitId = null;
        _startCoords = null;
        _startAddress = null;
        _endCoords = null;
        _endAddress = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOngoing = _ongoingTransitId != null;

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
            isOngoing
                ? ElevatedButton.icon(
              onPressed: _completeTransit,
              icon: const Icon(Icons.check),
              label: const Text("Complete Transit"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
            )
                : ElevatedButton.icon(
              onPressed: _saveTransit,
              icon: const Icon(Icons.save),
              label: const Text("Start Transit"),
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
