import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/location_services/driver_location_transit_service.dart';
// 💡 Import the new service that calls the Fastify backend proxy
import '../services/transit_api_service.dart';

class DriverLiveTransitScreen extends StatefulWidget {
  const DriverLiveTransitScreen({super.key});
  @override
  State<DriverLiveTransitScreen> createState() => _DriverLiveTransitScreenState();
}

class _DriverLiveTransitScreenState extends State<DriverLiveTransitScreen> {
  GoogleMapController? _mapController;

  // 🗑️ REMOVED: static const String _GOOGLE_API_KEY = '...';

  // 💡 NEW: Instance of the proxy API service
  final TransitApiService _apiService = TransitApiService();

  // default: Chennai
  static const LatLng _defaultCenter = LatLng(13.0827, 80.2707);

  List<Map<String, dynamic>> drivers = [];
  String? selectedDriverId;
  String? selectedDriverPhone;

  Map<String, dynamic>? ongoingTransit; // start/end/status
  Map<String, dynamic>? liveLocation;   // current lat/lng

  Timer? _pollTimer;
  bool isPolling = false;
  bool isLoading = false;
  String statusMessage = '';

  // map overlays
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // cached route (start->dest)
  List<LatLng> _routePoints = [];
  int? _routeDistanceMeters; // total route distance (Directions leg)
  int? _routeDurationSeconds;

  // live metrics
  int? _etaSecondsFromLive;    // ETA live->destination (Distance Matrix)
  int? _remainingMeters;       // live->destination (Distance Matrix)
  int? _coveredMeters;         // routeDistance - remaining (best), else haversine

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

  Future<void> _loadDrivers() async {
    setState(() => isLoading = true);
    try {
      // NOTE: Assuming this is a custom backend service, not Google API
      drivers = await DriverLocationTransitService.fetchDrivers();
    } catch (_) {
      drivers = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDriver(Map<String, dynamic> driver) async {
    selectedDriverId = driver['id']?.toString();
    selectedDriverPhone = driver['phone']?.toString();
    print('✅ Driver selected: ID=$selectedDriverId, Phone=$selectedDriverPhone');

    await _fetchTransitAndLocation();
    _startPolling();
    setState(() {});
  }

  Future<void> _fetchTransitAndLocation() async {
    if (selectedDriverId == null || selectedDriverPhone == null) return;
    setState(() => statusMessage = 'Fetching...');
    try {
      final transit = await DriverLocationTransitService.getOngoingTransit(selectedDriverId!);
      final live = await DriverLocationTransitService.getLiveLocationByPhone(selectedDriverPhone!);

      ongoingTransit = transit;
      liveLocation = live;

      if (liveLocation == null) {
        // MOCK LIVE LOCATION for testing map feature
        liveLocation = {
          'latitude': 12.5,  // Example coordinates between start and end
          'longitude': 78.5,
          'mocked': true,
        };
        print('✅ MOCK: Hardcoding Live Location for testing.');
      }


      statusMessage = (transit != null) ? 'Ongoing transit found' : 'No ongoing transit';
      print('ℹ️ Transit Status: $statusMessage');
      if (ongoingTransit == null) {
        print('⚠️ No ongoing transit data. Cannot fetch directions/polyline.');
      } else {
        print('Transit Data: ${ongoingTransit.toString()}');
      }
      if (liveLocation == null) {
        print('⚠️ No live location data.');
      } else {
        print('Live Location Data: ${liveLocation.toString()}');
      }

      await _refreshMapAndMetrics();
    } catch (e) {
      statusMessage = 'Failed to fetch data';
      print('❌ Error fetching custom service data: $e');
      setState(() {});
    }
  }

  void _startPolling({int intervalSeconds = 5}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      if (selectedDriverId == null || selectedDriverPhone == null) return;
      await _fetchTransitAndLocation();
    });
    setState(() => isPolling = true);
    print('⏰ Polling started every ${intervalSeconds}s.');
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    setState(() => isPolling = false);
    print('⏸️ Polling stopped.');
  }

  // ---- MAP + METRICS ----

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Future<void> _refreshMapAndMetrics() async {
    _markers.clear();
    _polylines.clear();
    _routePoints = [];
    _routeDistanceMeters = null;
    _routeDurationSeconds = null;
    _etaSecondsFromLive = null;
    _remainingMeters = null;
    _coveredMeters = null;

    LatLng? start, dest, live;

    if (ongoingTransit != null) {
      final sLat = _toDouble(ongoingTransit!['startLatitude']);
      final sLng = _toDouble(ongoingTransit!['startLongitude']);
      final dLat = _toDouble(ongoingTransit!['endLatitude']);
      final dLng = _toDouble(ongoingTransit!['endLongitude']);
      if (sLat != null && sLng != null) {
        start = LatLng(sLat, sLng);
        print('✅ Start Coordinates: $start');
      } else {
        print('⚠️ Start coordinates are invalid/missing in transit data.');
      }
      if (dLat != null && dLng != null) {
        dest = LatLng(dLat, dLng);
        print('✅ Destination Coordinates: $dest');
      } else {
        print('⚠️ Destination coordinates are invalid/missing in transit data.');
      }
    }
    if (liveLocation != null) {
      final lLat = _toDouble(liveLocation!['latitude']);
      final lLng = _toDouble(liveLocation!['longitude']);
      if (lLat != null && lLng != null) {
        live = LatLng(lLat, lLng);
        print('✅ Live Coordinates: $live');
      } else {
        print('⚠️ Live coordinates are invalid/missing in location data.');
      }
    }

    // Markers
    if (start != null) {
      _markers.add(Marker(
        markerId: const MarkerId('start'),
        position: start,
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (dest != null) {
      _markers.add(Marker(
        markerId: const MarkerId('dest'),
        position: dest,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    if (live != null) {
      _markers.add(Marker(
        markerId: const MarkerId('live'),
        position: live,
        infoWindow: const InfoWindow(title: 'Live'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    print('Markers added: ${_markers.length} (Start=${start!=null}, Dest=${dest!=null}, Live=${live!=null})');


    // Route polyline: start -> destination (via server proxy)
    if (start != null && dest != null) {
      await _fetchDirectionsProxy(start, dest);
    } else {
      print('⚠️ Skipping Directions API call: Missing Start or Destination.');
    }

    // Live ETA + remaining distance (live -> destination) (via server proxy)
    if (live != null && dest != null) {
      await _fetchDistanceMatrixProxy(live, dest);
    } else {
      print('⚠️ Skipping Distance Matrix API call: Missing Live or Destination.');
    }

    // Covered = routeDistance - remaining (best). Fallback = straight-line start->live.
    if (_routeDistanceMeters != null && _remainingMeters != null) {
      _coveredMeters = math.max(0, _routeDistanceMeters! - _remainingMeters!);
      print('✅ Covered distance calculated: $_coveredMeters meters (Route - Remaining)');
    } else if (start != null && live != null) {
      _coveredMeters = _haversineMeters(start, live);
      print('ℹ️ Covered distance fallback (Haversine): $_coveredMeters meters');
    } else {
      print('⚠️ Could not calculate covered distance (missing data).');
    }

    // Camera fit
    final pointsToFit = [
      if (start != null) start,
      if (dest != null) dest,
      if (live != null) live,
      if (start == null && dest == null && live == null) _defaultCenter,
    ];
    print('Camera fitting to ${pointsToFit.length} points.');
    await _fitBounds(pointsToFit);

    if (mounted) setState(() {
      print('Map state updated.');
    });
  }

  // -----------------------------------------------------------
  // 💡 UPDATED: _fetchDirectionsProxy - uses TransitApiService
  // -----------------------------------------------------------
  Future<void> _fetchDirectionsProxy(LatLng start, LatLng dest) async {
    print('Sending Directions API Request to: ${TransitApiService.BASE_URL}/directions (via Proxy)');
    try {
      final data = await _apiService.fetchDirectionsProxy(start, dest);

      if (data['status'] != 'OK') {
        print('❌ Proxy Directions API returned failure status: ${data['status']}');
        print('Error message: ${data['error_message']}');
        return;
      }

      final route = (data['routes'] as List).first;
      final leg = (route['legs'] as List).first;

      _routeDistanceMeters = leg['distance']?['value'];
      _routeDurationSeconds = leg['duration']?['value'];
      print('✅ Directions API Success (via Proxy): Distance=$_routeDistanceMeters m, Duration=$_routeDurationSeconds s.');

      final points = route['overview_polyline']?['points'];
      if (points is String) {
        _routePoints = _decodePolyline(points);
        if (_routePoints.isNotEmpty) {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints,
            width: 6,
            color: Colors.blue,
          ));
          print('✅ Polyline added with ${_routePoints.length} points.');
        }
      }
    } catch (e) {
      print('❌ Error fetching directions via proxy: $e');
    }
  }


  // -----------------------------------------------------------
  // 💡 UPDATED: _fetchDistanceMatrixProxy - uses TransitApiService
  // -----------------------------------------------------------
  Future<void> _fetchDistanceMatrixProxy(LatLng origin, LatLng dest) async {
    try {
      final data = await _apiService.fetchDistanceMatrixProxy(origin, dest);

      if (data['status'] != 'OK') {
        print('❌ Proxy Distance Matrix API returned failure status: ${data['status']}');
        return;
      }

      final rows = data['rows'] as List?;
      if (rows == null || rows.isEmpty) return;
      final elements = rows.first['elements'] as List?;
      if (elements == null || elements.isEmpty) return;
      final el = elements.first;

      if (el['status'] == 'OK') {
        _remainingMeters = el['distance']?['value'];
        _etaSecondsFromLive = (el['duration_in_traffic'] ?? el['duration'])?['value'];
        print('✅ Distance Matrix Success (via Proxy): Remaining=$_remainingMeters m, ETA=$_etaSecondsFromLive s.');
      } else {
        print('❌ Distance Matrix Element Status: ${el['status']}');
      }
    } catch (e) {
      print('❌ Error fetching distance matrix via proxy: $e');
    }
  }


  // camera fit helper
  Future<void> _fitBounds(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) return;
    if (points.length == 1) {
      await _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: points.first, zoom: 13),
      ));
      return;
    }
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points.skip(1)) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // polyline decoder (encoded polyline algorithm)
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // fast haversine (meters) for fallback covered
  int _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLng = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude), la2 = _deg2rad(b.latitude);
    final h = math.sin(dLat/2)*math.sin(dLat/2)
        + math.cos(la1)*math.cos(la2)*math.sin(dLng/2)*math.sin(dLng/2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1-h));
    return (R * c).round();
  }
  double _deg2rad(double d) => d * math.pi / 180.0;

  String _fmtKm(int? m) => m == null ? '-' : (m / 1000).toStringAsFixed(2);
  String _fmtEta(int? s) {
    if (s == null) return '-';
    final d = Duration(seconds: s);
    return d.inHours > 0 ? '${d.inHours}h ${d.inMinutes % 60}m' : '${d.inMinutes}m';
  }

  // ---- UI ----

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
              return DropdownMenuItem<Map<String, dynamic>>(value: d, child: Text(display));
            }).toList(),
            onChanged: (d) { if (d != null) _selectDriver(d); },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            await _fetchTransitAndLocation();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshed')));
            }
          },
        ),
      ],
    );
  }

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
    final status = ongoingTransit!['status'] ?? 'ONGOING';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Transit: ${ongoingTransit!['id'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Status: $status'),
          Text('Started: ${startedAt ?? 'Unknown'}'),
          if (liveLocation != null)
            Text('Live: ${liveLocation!['latitude']}, ${liveLocation!['longitude']}'),
          const Divider(),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _statChip('Route km', _fmtKm(_routeDistanceMeters)),
            _statChip('Covered km', _fmtKm(_coveredMeters)),
            _statChip('Ahead km', _fmtKm(_remainingMeters)),
            _statChip('ETA', _fmtEta(_etaSecondsFromLive ?? _routeDurationSeconds)),
          ]),
        ]),
      ),
    );
  }

  Widget _statChip(String label, String value) => Chip(label: Text('$label: $value'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Live & Transit (Server Proxy)'),
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
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(target: _defaultCenter, zoom: 12),
              onMapCreated: (c) => _mapController = c,
              markers: _markers,
              polylines: _polylines,
              zoomControlsEnabled: true,
              trafficEnabled: true,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}