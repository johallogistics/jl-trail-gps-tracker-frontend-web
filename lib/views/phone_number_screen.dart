import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_manager.dart';
import '../utils/device_utils.dart';
import 'home_screen.dart';
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
  final box = GetStorage();

  // REVIEWER / TEST PHONES
  // You may include full +91 prefixed numbers or plain 10-digit numbers.
  // Keep this list updated with the test numbers you created on the server.
  final List<String> reviewerPhones = const [
    '+918888888888', // example
    '+919999999999', // example
    '8888888888',    // support plain 10-digit input as well
    '9999999999',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Set the default prefix and position the cursor after it.
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
      final cursorPosition = phoneController.selection.start;

      if (cursorPosition < prefix.length) {
        phoneController.text = prefix;
        phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: prefix.length),
        );
      } else {
        final newText = prefix + text.replaceAll(RegExp(r'^\+?91'), '').replaceAll(RegExp(r'\D'), '');
        phoneController.value = phoneController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  // Normalize phone to full +91XXXXXXXXXX form for matching
  String _normalizePhone(String raw) {
    var p = raw.trim();
    // If user typed just 10 digits, add +91
    if (RegExp(r'^\d{10}$').hasMatch(p)) {
      return '+91$p';
    }
    // If user typed +91 followed by 10 digits, keep it
    if (RegExp(r'^\+91\d{10}$').hasMatch(p)) {
      return p;
    }
    // If user typed something like 919xxxxxxxxx, convert to +91...
    if (RegExp(r'^91\d{10}$').hasMatch(p)) {
      return '+${p.substring(0)}';
    }
    // fallback: return trimmed input
    return p;
  }

  bool _isReviewerPhone(String normalizedPlus91) {
    // allow reviewerPhones to be stored either as +91 form or plain 10-digit
    final plain10 = normalizedPlus91.replaceFirst('+91', '');
    return reviewerPhones.contains(normalizedPlus91) || reviewerPhones.contains(plain10);
  }

  Future<void> sendOTP() async {
    String phoneRaw = phoneController.text.trim();

    // Quick normalization attempt: allow user to enter either +91XXXXXXXXXX or XXXXXXXXXX
    final normalized = _normalizePhone(phoneRaw);

    // Validate
    if (!RegExp(r'^\+91\d{10}$').hasMatch(normalized)) {
      Get.snackbar(
        'Error',
        'Enter a valid 10-digit number (e.g., +919876543210)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // If this is a reviewer/test account -> bypass OTP sending (client-side)
    final isReviewer = _isReviewerPhone(normalized);
    if (isReviewer) {
      // Save reviewer metadata locally so Splash/other logic can detect it
      await box.write('phone', normalized);
      await box.write('isReviewer', true);

      // Optionally you can store a flag so your Splash or server side can skip device lock check
      Get.snackbar(
        'Reviewer mode',
        'Reviewer account detected — bypassing OTP and device checks on client.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to LoginScreen where the reviewer can proceed.
      // Your server should also allow this phone to login without deviceId restriction, or accept a fixed OTP.
      Get.to(() => HomeScreen());
      return;
    }

    // Normal app flow (send OTP)
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("https://$BACKEND_BASE_URL/send-otp");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': normalized}),
      );

      if (response.statusCode == 200) {
        // Save phone locally
        await box.write('phone', normalized);
        // ensure reviewer flag cleared
        await box.write('isReviewer', false);

        final deviceId = await DeviceUtils.getDeviceId();
        debugPrint('deviceId: $deviceId');

        // Navigate to OTP screen (LoginScreen)
        Get.to(() => LoginScreen(phoneNumber: normalized));
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
                // Allow digits and plus sign
                FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                // Limit total characters to 13 (+91 and 10 digits)
                LengthLimitingTextInputFormatter(13),
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number',
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
