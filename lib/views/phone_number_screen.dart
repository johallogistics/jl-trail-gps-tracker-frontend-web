import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_manager.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar('Error', 'Enter a valid phone number',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    try {
      var url = Uri.parse("https://jl-trail-gps-tracker-backend-production.up.railway.app/send-otp");

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        Get.to(() => LoginScreen(phoneNumber: phone));  // Navigate to OTP Screen
      } else {
        Get.snackbar('Error', 'Failed to send OTP', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Server error! Try again later.', snackPosition: SnackPosition.BOTTOM);
    }

    setState(() => isLoading = false);
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
