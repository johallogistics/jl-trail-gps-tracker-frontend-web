import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
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

  String BACKEND_BASE_URL = "jl-trail-gps-tracker-backend-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    // 1. Set the default prefix and position the cursor after it.
    // We only do this if the controller is empty (to prevent overwriting pre-filled data)
    if (phoneController.text.isEmpty) {
      phoneController.text = '+91';
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length),
      );
    }
    // Add listener to ensure the +91 prefix is always present and the user cannot delete it
    phoneController.addListener(_ensurePrefix);
  }

  @override
  void dispose() {
    phoneController.removeListener(_ensurePrefix);
    phoneController.dispose();
    super.dispose();
  }

  // Helper method to ensure the +91 prefix is retained
  void _ensurePrefix() {
    final text = phoneController.text;
    const prefix = '+91';

    if (!text.startsWith(prefix)) {
      // If the prefix is deleted, revert the text back to the prefix
      final cursorPosition = phoneController.selection.start;

      // If the cursor is at the beginning, assume they tried to delete the '+'
      if (cursorPosition < prefix.length) {
        phoneController.text = prefix;
        phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: prefix.length),
        );
      } else {
        // This handles cases where user pastes something without the prefix
        final newText = prefix + text.replaceAll(RegExp(r'^\+?91'), '').replaceAll(RegExp(r'\D'), '');
        phoneController.value = phoneController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }


  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();

    // The full phone number should be 13 characters (+91 and 10 digits)
    if (phone.length != 13 || !phone.startsWith('+91')) {
      Get.snackbar(
        'Error',
        'Enter a valid 10-digit number (e.g., +919876543210)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("https://$BACKEND_BASE_URL/send-otp");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // phone already has '+91'
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        // Save phone locally
        final box = GetStorage();
        box.write('phone', phone);
        final deviceId = await DeviceUtils.getDeviceId();
        debugPrint('deviceId: $deviceId');

        // Navigate to OTP screen
        Get.to(() => LoginScreen(phoneNumber: phone));
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Phone Verification'),
        backgroundColor: Colors.blueAccent[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(),
            Text(
              'Enter your 10-digit phone number to receive an OTP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 20),
            // === MODIFIED TEXTFIELD ===
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              // Apply formatters to restrict input
              inputFormatters: [
                // 2. Allow only digits
                FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                // 3. Limit total characters to 13 (+91 and 10 digits)
                LengthLimitingTextInputFormatter(13),
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number',
                // Explicitly show the prefix text in the decoration
                // prefixText: '+91',
                prefixIcon: Icon(Icons.phone, color: Colors.blueAccent[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent[700]!),
                ),
              ),
            ),
            // === END MODIFIED TEXTFIELD ===
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : sendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
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