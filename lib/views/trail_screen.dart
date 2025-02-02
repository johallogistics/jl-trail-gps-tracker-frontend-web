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

  @override
  void initState() {
    super.initState();
    // _startTrackingLocation();
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
    final String apiUrl = 'http://localhost:3000/update-location';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'driverId': 'driver123',
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
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
      appBar: AppBar(
        title: Text('trail_screen'.tr),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPosition != null)
              Text(
                '${'current_location'.tr} \nLat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Text('${'employee_name'.tr}: ${employeeData['name']}'),
            Text('${'employee_phone'.tr}: ${employeeData['phone']}'),
            Text('${'employee_code'.tr}: ${employeeData['code']}'),
            Text('${'month'.tr}: ${employeeData['month']}'),
            Text('${'year'.tr}: ${employeeData['year']}'),
            Text('${'incharge_name'.tr}: ${employeeData['inchargeName']}'),
            Text('${'incharge_phone'.tr}: ${employeeData['inchargePhone']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => DailyReportScreen(employeeData: employeeData));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blue,
              ),
              child: Text('open_daily_report'.tr),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => FormScreen());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blue,
              ),
              child: Text('open_consolidated_report'.tr),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _stopTrackingLocation();
                print('Trail Completed');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.green,
              ),
              child: Text('complete_trail'.tr),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.to(() => ShiftLogDetailScreen());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blue,
              ),
              child: Text('Test Google Translate --> Trail Data'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
