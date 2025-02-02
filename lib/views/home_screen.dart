import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/controllers/trail_controller.dart';
import 'package:trail_tracker/views/trail_screen.dart';
import 'package:trail_tracker/views/transit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the TrailController
    final TrailController trailController = Get.put(TrailController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'.tr),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          DropdownButton<String>(
            value: Get.locale?.languageCode,
            icon: Icon(Icons.language, color: Colors.white),
            items: [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
            onChanged: (String? langCode) {
              if (langCode != null) {
                Get.updateLocale(Locale(langCode));
              }
            },
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
                print('Start Transit Clicked');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: Text('Start Transit'.tr),
            ),
            const SizedBox(height: 20),

            // Use Obx to reactively update the button based on the active trail status
            Obx(() {
              if (trailController.hasActiveTrail.value == null) {
                return const CircularProgressIndicator(); // Show loading
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
                    minimumSize: const Size(200, 50),
                    backgroundColor: trailController.hasActiveTrail.value
                        ? Colors.orange
                        : Colors.green,
                  ),
                  child: Text(
                      trailController.hasActiveTrail.value
                          ? 'Continue Trail'.tr
                          : 'Start Trail'.tr),
                );
              }
            }
            ),
          ],
        ),
      ),
    );
  }
}
