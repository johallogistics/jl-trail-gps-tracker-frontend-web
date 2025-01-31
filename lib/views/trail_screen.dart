import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trail_tracker/views/daily_report_screen.dart'; // Your Daily Report Form Screen
import 'package:http/http.dart' as http;

import 'consolidated_report_screen.dart';

class TrailScreen extends StatefulWidget {
  final bool isContinuingTrail; // Flag to check if it's continue or start
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
    _startTrackingLocation();
  }

  // Start tracking the location
  void _startTrackingLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _sendLocationToServer(position.latitude, position.longitude);
    });
  }

  // Stop tracking location
  void _stopTrackingLocation() {
    setState(() {
      _isTracking = false;
    });
  }

  // Send live location to the server (Database)
  void _sendLocationToServer(double latitude, double longitude) async {
    // Replace with your API endpoint
    final String apiUrl = 'http://localhost:3000/update-location';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'driverId': 'driver123', // Replace with actual driver ID
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
    // Stop the location tracking when the screen is disposed
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
        title: const Text('Trail Screen'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPosition != null)
              Text(
                'Current Location: \nLat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}',
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            Text('Employee Name: ${employeeData['name']}'),
            Text('Employee Phone: ${employeeData['phone']}'),
            Text('Employee Code: ${employeeData['code']}'),
            Text('Month: ${employeeData['month']}'),
            Text('Year: ${employeeData['year']}'),
            Text('DICV Incharge Name: ${employeeData['inchargeName']}'),
            Text('Incharge Phone: ${employeeData['inchargePhone']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Daily Report Screen
                Get.to(() =>  DailyReportScreen(employeeData: employeeData));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text('Open Daily Report Form'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Daily Report Screen
                Get.to(() =>  FormScreen());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text('Open Consolidated Report Form'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Complete the trail and stop location tracking
                _stopTrackingLocation();
                print('Trail Completed');
                // Maybe navigate or show a completion message
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text('Complete Trail'),
            ),
          ],
        ),
      ),
    );
  }
}
