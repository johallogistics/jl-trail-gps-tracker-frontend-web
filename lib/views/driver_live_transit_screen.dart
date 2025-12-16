import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // used ONLY for decoding

// Your own service imports
import '../utils/location_services/driver_location_transit_service.dart';
import '../services/transit_api_service.dart';

class DriverLiveTransitScreen extends StatefulWidget {
  const DriverLiveTransitScreen({super.key});
  @override
  State<DriverLiveTransitScreen> createState() => _DriverLiveTransitScreenState();
}

class _DriverLiveTransitScreenState extends State<DriverLiveTransitScreen> {
  GoogleMapController? _mapController;
  final TransitApiService _apiService = TransitApiService();

  // Start map in Lagos, Nigeria
  static const LatLng _defaultCenter = LatLng(6.6, 3.5);

  // State variables
  List<Map<String, dynamic>> drivers = [];
  String? selectedDriverId;
  String? selectedDriverPhone;
  Map<String, dynamic>? ongoingTransit;
  Map<String, dynamic>? liveLocation;
  Timer? _pollTimer;
  bool isPolling = false;
  bool isLoading = false;
  String statusMessage = '';

  // Map overlays
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Cached full route data
  List<LatLng> _routePoints = [];
  bool _hasFetchedRoute = false;
  int? _routeDistanceMeters;
  int? _routeDurationSeconds;

  // Live metrics
  int? _etaSecondsFromLive;
  int? _remainingMeters;
  int? _coveredMeters;

  bool _hasFittedInitialBounds = false;


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
  // imports
// add to your State class
  final Map<String, BitmapDescriptor> _iconCache = {};

  Future<BitmapDescriptor> _startIcon() async {
    if (kIsWeb) return _pinWithLabel('start', 'Start', Colors.green);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

  Future<BitmapDescriptor> _destIcon() async {
    if (kIsWeb) return _pinWithLabel('dest', 'Destination', Colors.red);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  Future<BitmapDescriptor> _liveIcon() async {
    if (kIsWeb) return _pinWithLabel('live', 'Live', Colors.yellow);
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }

  Future<BitmapDescriptor> _pinWithLabel(String key, String label, Color color) async {
    if (_iconCache.containsKey(key)) return _iconCache[key]!;

    // Logical size; will be scaled by DPR for sharpness.
    const double w = 96;   // width in logical px
    const double h = 120;  // height including label
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final pr = ui.PictureRecorder();
    final canvas = Canvas(pr);

    // Scale canvas so all drawing uses logical coords but raster is hi-dpi.
    canvas.scale(dpr);

    // Pin geometry
    const pinCenter = Offset(w / 2, 34);
    const headR = 16.0;
    final pinPath = Path()
      ..addOval(Rect.fromCircle(center: pinCenter, radius: headR))
      ..moveTo(pinCenter.dx - 10, pinCenter.dy + 10)
      ..lineTo(pinCenter.dx, pinCenter.dy + 30)
      ..lineTo(pinCenter.dx + 10, pinCenter.dy + 10)
      ..close();

    // Shadow
    final shadow = Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    final shadowPath = pinPath.shift(const Offset(0, 2));
    canvas.drawPath(shadowPath, shadow);

    // Pin fill
    final fill = Paint()..color = color;
    canvas.drawPath(pinPath, fill);

    // White stroke for contrast
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;
    canvas.drawPath(pinPath, stroke);

    // Inner white dot (like Google’s)
    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(pinCenter, 6, inner);

    // Label pill background
    const double padX = 8;
    const double padY = 4;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 12,              // smaller, readable
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: w - 16);

    final pillW = tp.width + padX * 2;
    final pillH = tp.height + padY * 2;
    final pillLeft = (w - pillW) / 2;
    const pillTop = 78.0;

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pillLeft, pillTop, pillW, pillH),
      const Radius.circular(12),
    );

    // Pill shadow
    final pillShadow = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2);
    canvas.drawRRect(pillRect.shift(const Offset(0, 1)), pillShadow);

    // Pill fill + stroke
    final pillFill = Paint()..color = Colors.white;
    canvas.drawRRect(pillRect, pillFill);

    final pillStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x22000000);
    canvas.drawRRect(pillRect, pillStroke);

    // Draw text centered in pill
    final textOffset = Offset(
      pillLeft + padX,
      pillTop + padY - 1, // tiny optical adjustment
    );
    tp.paint(canvas, textOffset);

    // Rasterize at device pixels
    final img = await pr.endRecording().toImage((w * dpr).toInt(), (h * dpr).toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    _iconCache[key] = icon;
    return icon;
  }

  Future<void> _loadDrivers() async {
    setState(() => isLoading = true);
    try {
      drivers = await DriverLocationTransitService.fetchDrivers();
    } catch (_) {
      drivers = [];
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _selectDriver(Map<String, dynamic> driver) async {
    setState(() {
      _stopPolling();
      isLoading = true;
      selectedDriverId = driver['id']?.toString();
      selectedDriverPhone = driver['phone']?.toString();
      _hasFetchedRoute = false;
      _markers.clear();
      _polylines.clear();
      _routePoints = [];
      ongoingTransit = null;
      liveLocation = null;
      statusMessage = '';
      _hasFittedInitialBounds = false;
    });

    debugPrint('✅ Driver selected: ID=$selectedDriverId, Phone=$selectedDriverPhone');

    try {
      ongoingTransit = await DriverLocationTransitService.getOngoingTransit(selectedDriverId!);
      if (ongoingTransit == null) {
        statusMessage = 'No ongoing transit for this driver.';
        debugPrint('⚠️ No ongoing transit data. Cannot fetch directions.');
        if (mounted) setState(() => isLoading = false);
        return;
      }
      await _pollLiveLocationAndUpdateMap();
    } catch (e) {
      statusMessage = 'Failed to fetch initial transit data.';
      debugPrint('❌ Error during initial fetch: $e');
      if (mounted) setState(() => isLoading = false);
      return;
    }
    _startPolling();
  }

  Future<void> _pollLiveLocationAndUpdateMap() async {
    if (selectedDriverId == null || selectedDriverPhone == null) return;
    try {
      final live = await DriverLocationTransitService.getLiveLocationByPhone(selectedDriverPhone!);
      if (live == null) debugPrint('⚠️ Polling: No live location data found.');
      liveLocation = live;
      await _refreshMapAndMetrics();
    } catch (e) {
      debugPrint('❌ Error polling live location: $e');
    }
  }

  void _startPolling({int intervalSeconds = 5}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      await _pollLiveLocationAndUpdateMap();
    });
    if (mounted) setState(() => isPolling = true);
    debugPrint('⏰ Polling started every ${intervalSeconds}s.');
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    if (mounted) setState(() => isPolling = false);
    debugPrint('⏸️ Polling stopped.');
  }

  Future<void> _refreshMapAndMetrics() async {
    final Set<Marker> currentMarkers = {};
    final Set<Polyline> currentPolylines = {};
    LatLng? start, dest, live;

    if (ongoingTransit != null) {
      final sLat = _toDouble(ongoingTransit!['startLatitude']);
      final sLng = _toDouble(ongoingTransit!['startLongitude']);
      final dLat = _toDouble(ongoingTransit!['endLatitude']);
      final dLng = _toDouble(ongoingTransit!['endLongitude']);
      if (sLat != null && sLng != null) start = LatLng(sLat, sLng);
      if (dLat != null && dLng != null) dest = LatLng(dLat, dLng);
    }
    if (liveLocation != null) {
      final lLat = _toDouble(liveLocation!['latitude']);
      final lLng = _toDouble(liveLocation!['longitude']);
      if (lLat != null && lLng != null) live = LatLng(lLat, lLng);
    }

    if (start != null && dest != null && !_hasFetchedRoute) {
      await _fetchDirectionsAndDecodeWithPackage(start, dest);
      _hasFetchedRoute = _routePoints.isNotEmpty;
    }

    if (start != null) {
      currentMarkers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: start,
          infoWindow: const InfoWindow(title: 'Start'),
          icon: await _startIcon(),
        ),
      );
    }

    if (dest != null) {
      currentMarkers.add(
        Marker(
          markerId: const MarkerId('dest'),
          position: dest,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: await _destIcon(),
        ),
      );
    }

    if (live != null) {
      currentMarkers.add(
        Marker(
          markerId: const MarkerId('live'),
          position: live,
          infoWindow: const InfoWindow(title: 'Live Location'),
          icon: await _liveIcon(),
        ),
      );
    }


    if (_routePoints.isNotEmpty) {
      debugPrint('👣 First 3 pts from package decoder: ${_routePoints.take(3).toList()}');
      currentPolylines.add(
        Polyline(
          polylineId: const PolylineId('full_route'),
          points: _routePoints,
          width: 6,
          color: Colors.blue,
          zIndex: 1,
        ),
      );
      debugPrint('✅ Preparing to draw full route polyline with ${_routePoints.length} points.');
    }

    if (live != null && dest != null) {
      await _fetchDistanceMatrixProxy(live, dest);
    }

    if (start != null && live != null) {
      _coveredMeters = _haversineMeters(start, live);
    } else {
      _coveredMeters = null;
    }

    final pointsToFit = <LatLng>[
      if (start != null) start,
      if (dest != null) dest,
      if (live != null) live,
      if (start == null && dest == null && live == null) _defaultCenter,
    ];

    if (!_hasFittedInitialBounds && pointsToFit.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fitBounds(pointsToFit);
        _hasFittedInitialBounds = true;
      });
    }


    if (mounted) {
      setState(() {
        _markers
          ..clear()
          ..addAll(currentMarkers);
        _polylines
          ..clear()
          ..addAll(currentPolylines);
        isLoading = false;
      });
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  /// Fetch directions via your backend proxy and decode with `flutter_polyline_points`.
  Future<void> _fetchDirectionsAndDecodeWithPackage(LatLng start, LatLng dest) async {
    debugPrint('➡️ Fetching directions from server proxy (CORS-safe).');
    try {
      final data = await _apiService.fetchDirectionsProxy(start, dest);

      if (data['status'] != 'OK') {
        debugPrint('❌ Proxy Directions API returned failure status: ${data['status']}');
        _routePoints = [start, dest];
        return;
      }

      final routes = (data['routes'] as List?) ?? const [];
      if (routes.isEmpty) {
        debugPrint('❌ No routes returned.');
        _routePoints = [start, dest];
        return;
      }

      final overviewPolyline = routes.first['overview_polyline']?['points'] as String?;
      if (overviewPolyline == null || overviewPolyline.isEmpty) {
        debugPrint('❌ overview_polyline.points missing!');
        _routePoints = [start, dest];
        return;
      }

      debugPrint('👍 Received overview_polyline from server. Decoding with flutter_polyline_points...');

      // ✅ Static decode — no apiKey, no instance
      final List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(overviewPolyline);

      if (decodedPoints.isNotEmpty) {
        _routePoints = decodedPoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(growable: false);
        debugPrint('✅ Package successfully decoded a route with ${_routePoints.length} points.');
      } else {
        debugPrint('❌ The package failed to decode the string from the server.');
        _routePoints = [start, dest];
      }

      // Distance / duration (optional)
      try {
        final leg = (routes.first['legs'] as List?)?.first;
        _routeDistanceMeters = leg?['distance']?['value'];
        _routeDurationSeconds = leg?['duration']?['value'];
        if (_routeDistanceMeters != null) {
          debugPrint('✅ Directions: Distance=$_routeDistanceMeters m, Duration=$_routeDurationSeconds s.');
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('❌ FATAL Error in _fetchDirectionsAndDecodeWithPackage: $e');
      _routePoints = [start, dest];
    }
  }

  Future<void> _fetchDistanceMatrixProxy(LatLng origin, LatLng dest) async {
    try {
      final data = await _apiService.fetchDistanceMatrixProxy(origin, dest);
      if (data['status'] != 'OK') {
        debugPrint('❌ Proxy Distance Matrix API returned failure status: ${data['status']}');
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
        debugPrint('✅ Distance Matrix Success: Remaining=$_remainingMeters m, ETA=$_etaSecondsFromLive s.');
      } else {
        debugPrint('❌ Distance Matrix Element Status: ${el['status']}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching distance matrix via proxy: $e');
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) return;

    if (points.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: points.first, zoom: 13),
        ),
      );
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

    // Padding ~80 pixels around bounds
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  int _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * (math.pi / 180.0);
    final dLng = (b.longitude - a.longitude) * (math.pi / 180.0);
    final la1 = a.latitude * (math.pi / 180.0);
    final la2 = b.latitude * (math.pi / 180.0);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return (R * c).round();
  }

  String _fmtKm(int? m) => m == null ? '-' : (m / 1000).toStringAsFixed(2);

  String _fmtEta(int? s) {
    if (s == null) return '-';
    final d = Duration(seconds: s);
    return d.inHours > 0 ? '${d.inHours}h ${d.inMinutes % 60}m' : '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Live Transit'),
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
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(target: _defaultCenter, zoom: 12),
                  onMapCreated: (c) => _mapController = c,
                  markers: _markers,
                  polylines: _polylines,
                  zoomControlsEnabled: true,
                  trafficEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final points = _markers.map((m) => m.position).toList();
            await _fitBounds(points);
          },
          child: const Icon(Icons.my_location),
        )
    );
  }

  Widget _buildDriverSelector() {
    final selected = (selectedDriverId == null ||
        drivers.where((d) => d['id'].toString() == selectedDriverId).isEmpty)
        ? null
        : drivers.firstWhere((d) => d['id'].toString() == selectedDriverId);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Map<String, dynamic>>(
            value: selected,
            hint: const Text('Select driver'),
            items: drivers.map((d) {
              final display =
              (d['name'] ?? d['phone'] ?? d['employeeId'] ?? 'Driver').toString();
              return DropdownMenuItem<Map<String, dynamic>>(
                value: d,
                child: Text(display),
              );
            }).toList(),
            onChanged: (d) {
              if (d != null) _selectDriver(d);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            await _pollLiveLocationAndUpdateMap();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshed')));
            }
          },
        ),
      ],
    );
  }

  Widget _buildTransitInfo() {
    if (selectedDriverId == null || isLoading) return const SizedBox();
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
          Text('Transit: ${ongoingTransit!['id'] ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Status: $status'),
          Text('Started: ${startedAt ?? 'Unknown'}'),
          if (liveLocation != null)
            Text('Live: ${liveLocation!['latitude']}, ${liveLocation!['longitude']}'),
          const Divider(),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _statChip('Route', _fmtKm(_routeDistanceMeters)),
              _statChip('Covered', _fmtKm(_coveredMeters)),
              _statChip('Ahead', _fmtKm(_remainingMeters)),
              _statChip('ETA', _fmtEta(_etaSecondsFromLive)),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _statChip(String label, String value) => Chip(label: Text('$label: $value'));
}
