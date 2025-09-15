import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_manager.dart';
import '../utils/device_utils.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  String BACKEND_BASE_URL = "https://jl-trail-gps-tracker-backend-production.up.railway.app";

  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar(
        'Error',
        'Enter a valid phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Normalize phone to +<countrycode><number>
      final sendPhone = phone.startsWith('+') ? phone : '+$phone';

      final url = Uri.parse("https://$BACKEND_BASE_URL/send-otp");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': sendPhone}),
      );

      if (response.statusCode == 200) {
        // Save phone locally
        final box = GetStorage();
        box.write('phone', sendPhone);
        // get deviceId (we don't pass it into LoginScreen because LoginScreen will fetch it)
        final deviceId = await DeviceUtils.getDeviceId();
        debugPrint('deviceId: $deviceId');

        // Navigate to OTP screen (only pass phone — LoginScreen handles deviceId internally)
        Get.to(() => LoginScreen(phoneNumber: sendPhone));
      } else {
        Get.snackbar(
          'Error',
          'Failed to send OTP',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Server error! Try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('sendOTP error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // ✅ Soft Blue Background
      appBar: AppBar(
        title: const Text('Phone Verification'),
        backgroundColor: Colors.blueAccent[700], // ✅ Deep Blue AppBar
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(

            ),
            Text(
              'Enter your phone number to receive an OTP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone, color: Colors.blueAccent[700]), // ✅ Blue Icon
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent[700]!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : sendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700], // ✅ Blue Button
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send OTP', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
