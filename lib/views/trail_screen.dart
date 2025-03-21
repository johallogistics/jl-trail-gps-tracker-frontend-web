import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trail_tracker/views/daily_report_screen.dart';
import 'package:http/http.dart' as http;
import 'package:trail_tracker/views/shift_log_detail_screen.dart';
import 'consolidated_report_screen.dart';

class TrailScreen extends StatefulWidget {
  final bool isContinuingTrail;
  const TrailScreen({super.key, required this.isContinuingTrail});

  @override
  _TrailScreenState createState() => _TrailScreenState();
}

class _TrailScreenState extends State<TrailScreen> {
  Position? _currentPosition;
  bool _isTracking = true;
  String _driverId = "0";


  String get driverId => _driverId;

  set driverId(String value) {
    _driverId = value;
  }

  @override
  void initState() {
    super.initState();
    _startTrackingLocation();
  }

  void _startTrackingLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _sendLocationToServer(position.latitude, position.longitude);
    });
  }

  void _stopTrackingLocation() {
    setState(() {
      _isTracking = false;
    });
  }

  void _sendLocationToServer(double latitude, double longitude) async {
    final String apiUrl = 'http://localhost:3000/location';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "driverId": 6,
        "latitude": latitude,
        "longitude": longitude,
        "isIdle": false
      },
    );

    if (response.statusCode == 200) {
      print('Location updated successfully');
    } else {
      print('Failed to update location');
    }
  }

  @override
  void dispose() {
    _stopTrackingLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeData = {
      'name': 'John Doe',
      'phone': '123-456-7890',
      'code': 'EMP123',
      'month': 'January',
      'year': '2025',
      'inchargeName': 'Jane Smith',
      'inchargePhone': '987-654-3210',
    };

    return Scaffold(
      backgroundColor: Colors.blue[50], // ✅ Soft blue background
      appBar: AppBar(
        title: Text('trail_screen'.tr),
        backgroundColor: Colors.blueAccent[700], // ✅ Deep blue AppBar
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPosition != null)
              Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${'current_location'.tr} \nLat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('employee_name'.tr, employeeData['name']!),
                    _buildInfoRow('employee_phone'.tr, employeeData['phone']!),
                    _buildInfoRow('employee_code'.tr, employeeData['code']!),
                    _buildInfoRow('month'.tr, employeeData['month']!),
                    _buildInfoRow('year'.tr, employeeData['year']!),
                    _buildInfoRow('incharge_name'.tr, employeeData['inchargeName']!),
                    _buildInfoRow('incharge_phone'.tr, employeeData['inchargePhone']!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildElevatedButton('open_daily_report'.tr, Colors.blueAccent[700], () {
              Get.to(() => DailyReportScreen(employeeData: employeeData));
            }),

            _buildElevatedButton('open_consolidated_report'.tr, Colors.blueAccent[700], () {
              Get.to(() => FormScreen());
            }),

            _buildElevatedButton('complete_trail'.tr, Colors.green[600]!, () {
              _stopTrackingLocation();
              print('Trail Completed');
            }),

            _buildElevatedButton('Test Google Translate --> Trail Data'.tr, Colors.blueAccent[700], () {
              Get.to(() => ShiftLogDetailScreen());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedButton(String text, Color? color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent[700])),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
