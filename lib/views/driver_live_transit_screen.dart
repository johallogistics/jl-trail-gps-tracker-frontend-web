import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../utils/location_services/driver_location_transit_service.dart';

class DriverLiveTransitScreen extends StatefulWidget {
  const DriverLiveTransitScreen({super.key});
  @override
  State<DriverLiveTransitScreen> createState() => _DriverLiveTransitScreenState();
}

class _DriverLiveTransitScreenState extends State<DriverLiveTransitScreen> {
  final MapController _mapController = MapController();

  List<Map<String, dynamic>> drivers = [];
  String? selectedDriverId;
  String? selectedDriverPhone;

  // transit and live location
  Map<String, dynamic>? ongoingTransit;
  Map<String, dynamic>? liveLocation;

  Timer? _pollTimer;
  bool isPolling = false;
  bool isLoading = false;
  String statusMessage = '';

  // default map center: Chennai
  LatLng mapCenter = LatLng(13.0827, 80.2707);

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // Load list of drivers for dropdown
  Future<void> _loadDrivers() async {
    setState(() => isLoading = true);
    try {
      drivers = await DriverLocationTransitService.fetchDrivers();
      debugPrint('Drivers loaded: ${drivers.length}');
    } catch (e, st) {
      debugPrint('Failed to load drivers: $e\n$st');
      drivers = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  // When admin selects a driver from dropdown
  Future<void> _selectDriver(Map<String, dynamic> driver) async {
    selectedDriverId = driver['id']?.toString();
    selectedDriverPhone = driver['phone']?.toString();

    debugPrint('Selected driver -> id: $selectedDriverId, phone: $selectedDriverPhone');

    await _fetchTransitAndLocation();

    // Start polling for updates
    _startPolling();

    // Ensure UI updates
    setState(() {});
  }

  // Fetch both transit and live location for selected driver
  Future<void> _fetchTransitAndLocation() async {
    if (selectedDriverId == null || selectedDriverPhone == null) return;
    setState(() => statusMessage = 'Fetching...');
    try {
      final transit = await DriverLocationTransitService.getOngoingTransit(selectedDriverId!);
      final live = await DriverLocationTransitService.getLiveLocationByPhone(selectedDriverPhone!);

      debugPrint('>>> fetched transit: $transit');
      debugPrint('>>> fetched live location: $live');

      setState(() {
        ongoingTransit = transit;
        liveLocation = live;
        statusMessage = (transit != null) ? 'Ongoing transit found' : 'No ongoing transit';
      });

      // After widget rebuild, update camera view to include markers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMapView();
      });
    } catch (e, st) {
      debugPrint('Error fetching transit/location: $e\n$st');
      setState(() => statusMessage = 'Failed to fetch data');
    }
  }

  void _startPolling({int intervalSeconds = 5}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      if (selectedDriverId == null || selectedDriverPhone == null) return;
      await _fetchTransitAndLocation();
    });
    setState(() => isPolling = true);
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    setState(() => isPolling = false);
  }

  Widget _buildDriverSelector() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedDriverId == null
                ? null
                : drivers.firstWhere(
                  (d) => d['id'].toString() == selectedDriverId,
              orElse: () => drivers.isNotEmpty ? drivers.first : {},
            ),
            hint: const Text('Select driver'),
            items: drivers.map((d) {
              final display = (d['name'] ?? d['phone'] ?? d['employeeId'] ?? 'Driver').toString();
              return DropdownMenuItem<Map<String, dynamic>>(
                value: d,
                child: Text(display),
              );
            }).toList(),
            onChanged: (d) {
              if (d != null) _selectDriver(d);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            await _fetchTransitAndLocation();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshed')));
          },
        ),
      ],
    );
  }

  // Convert various dynamic types to double safely
  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s);
  }

  // Build markers for start, end and live location
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Transit start marker
    if (ongoingTransit != null) {
      final sLat = _toDouble(ongoingTransit!['startLatitude']);
      final sLng = _toDouble(ongoingTransit!['startLongitude']);
      if (sLat != null && sLng != null) {
        markers.add(Marker(
          point: LatLng(sLat, sLng),
          width: 40,
          height: 40,
          builder: (ctx) => const Icon(Icons.play_circle_fill, color: Colors.green, size: 36),
        ));
      }

      // Transit end marker
      final eLat = _toDouble(ongoingTransit!['endLatitude']);
      final eLng = _toDouble(ongoingTransit!['endLongitude']);
      if (eLat != null && eLng != null) {
        markers.add(Marker(
          point: LatLng(eLat, eLng),
          width: 40,
          height: 40,
          builder: (ctx) => const Icon(Icons.flag, color: Colors.red, size: 36),
        ));
      }
    }

    // Live location marker
    if (liveLocation != null) {
      final lat = _toDouble(liveLocation!['latitude']);
      final lng = _toDouble(liveLocation!['longitude']);
      if (lat != null && lng != null) {
        markers.add(Marker(
          point: LatLng(lat, lng),
          width: 50,
          height: 50,
          builder: (ctx) => const Icon(Icons.location_on, color: Colors.blue, size: 44),
        ));
      }
    }

    debugPrint('Markers built: ${markers.length}');
    return markers;
  }

  // Try to fit map view to include all markers; fallback to center/move if fitBounds fails
  void _updateMapView() {
    final markers = _buildMarkers();
    if (markers.isEmpty) {
      _mapController.move(mapCenter, 12);
      return;
    }

    final points = markers.map((m) => m.point).toList();

    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitBounds(bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(60)));
    } catch (e) {
      // Some flutter_map versions or controllers may throw; fallback to average center
      try {
        final avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
        final avgLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
        _mapController.move(LatLng(avgLat, avgLng), 13);
        debugPrint('fitBounds failed: $e; moved to avg center $avgLat,$avgLng');
      } catch (e2) {
        debugPrint('Both fitBounds and fallback failed: $e / $e2');
        _mapController.move(mapCenter, 12);
      }
    }
  }

  // Build transit detail card
  Widget _buildTransitInfo() {
    if (selectedDriverId == null) return const SizedBox();
    if (ongoingTransit == null) {
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('No ongoing transit'),
        subtitle: Text(statusMessage),
      );
    }

    final startedAt = ongoingTransit!['startedAt'] ?? ongoingTransit!['createdAt'];
    final startedStr = startedAt != null ? startedAt.toString() : 'Unknown';
    final status = ongoingTransit!['status'] ?? 'ONGOING';

    final sLat = _toDouble(ongoingTransit!['startLatitude']);
    final sLng = _toDouble(ongoingTransit!['startLongitude']);
    final eLat = _toDouble(ongoingTransit!['endLatitude']);
    final eLng = _toDouble(ongoingTransit!['endLongitude']);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_car),
        title: Text('Transit: ${ongoingTransit!['id'] ?? '-'}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $status'),
            Text('Started: $startedStr'),
            if (liveLocation != null)
              Text('Live: ${liveLocation!['latitude']}, ${liveLocation!['longitude']}'),
            if (sLat != null && sLng != null) Text('Start: $sLat, $sLng'),
            if (eLat != null && eLng != null) Text('Destination: $eLat, $eLng'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Live & Transit'),
        actions: [
          IconButton(
            icon: Icon(isPolling ? Icons.pause_circle_filled : Icons.play_circle_fill),
            onPressed: () => isPolling ? _stopPolling() : _startPolling(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(8), child: _buildDriverSelector()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: _buildTransitInfo()),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: mapCenter,
                zoom: 12.0,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),

                // Polyline between start and live (only if both points valid)
                if (ongoingTransit != null && liveLocation != null)
                  Builder(builder: (ctx) {
                    final sLat = _toDouble(ongoingTransit!['startLatitude']);
                    final sLng = _toDouble(ongoingTransit!['startLongitude']);
                    final lLat = _toDouble(liveLocation!['latitude']);
                    final lLng = _toDouble(liveLocation!['longitude']);

                    if (sLat != null && sLng != null && lLat != null && lLng != null) {
                      return PolylineLayer(
                        polylines: [
                          Polyline(points: [LatLng(sLat, sLng), LatLng(lLat, lLng)], strokeWidth: 4.0),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                MarkerLayer(markers: markers),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
