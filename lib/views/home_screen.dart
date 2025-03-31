import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/controllers/trail_controller.dart';
import 'package:trail_tracker/views/trail_screen.dart';
import 'package:trail_tracker/views/transit_screen.dart';

import '../utils/location_service.dart';


class HomeScreen extends StatelessWidget {

  String phone;

  HomeScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    // Initialize the TrailController
    final TrailController trailController = Get.put(TrailController());
    final LocationPostService locationService = LocationPostService();

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Home Screen'.tr),
        backgroundColor: Colors.blueAccent[700],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: Get.locale?.languageCode,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.language, color: Colors.white),
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.blueAccent[700]))),
                DropdownMenuItem(value: 'ta', child: Text('தமிழ்', style: TextStyle(color: Colors.blueAccent[700]))),
                DropdownMenuItem(value: 'hi', child: Text('हिन्दी', style: TextStyle(color: Colors.blueAccent[700]))),
                DropdownMenuItem(value: 'te', child: Text('తెలుగు', style: TextStyle(color: Colors.blueAccent[700]))),
                DropdownMenuItem(value: 'ml', child: Text('മലയാളം', style: TextStyle(color: Colors.blueAccent[700]))),
                DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ', style: TextStyle(color: Colors.blueAccent[700]))),
              ],
              onChanged: (String? langCode) {
                if (langCode != null) {
                  Get.updateLocale(Locale(langCode));
                }
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => TransitScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700], // ✅ Deep blue button
                foregroundColor: Colors.white,
                minimumSize: const Size(220, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Start Transit'.tr, style: const TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () => locationService.startTracking(phone),
              child: Text('Start Tracking'),
            ),
            ElevatedButton(
              onPressed: locationService.stopTracking,
              child: Text('Stop Tracking'),
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (trailController.hasActiveTrail.value == null) {
                return const CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () {
                    if (trailController.hasActiveTrail.value) {
                      print('Continue Active Trail');
                      // Navigate to continue trail screen or handle accordingly
                    } else {
                      Get.to(() => TrailScreen(isContinuingTrail: trailController.hasActiveTrail.value));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: trailController.hasActiveTrail.value
                        ? Colors.orange[700]
                        : Colors.green[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(220, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    trailController.hasActiveTrail.value
                        ? 'Continue Trail'.tr
                        : 'Start Trail'.tr,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
