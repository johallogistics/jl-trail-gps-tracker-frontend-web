import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../api/api_manager.dart';
import '../utils/device_utils.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String phoneNumber;
  const LoginScreen({super.key, required this.phoneNumber});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with CodeAutoFill {
  String otpCode = "";
  bool isResendEnabled = false;
  int resendCountdown = 30;
  final box = GetStorage();
  late String phoneNumber;
  bool isLoading = false;

  @override
  void initState() {
    phoneNumber = widget.phoneNumber;
    super.initState();
    listenForCode();
    startResendCountdown();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code ?? "";
    });
  }

  void startResendCountdown() {
    setState(() => isResendEnabled = false);
    resendCountdown = 30;
    Future.doWhile(() async {
      if (resendCountdown > 0) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() => resendCountdown--);
        return true;
      } else {
        setState(() => isResendEnabled = true);
        return false;
      }
    });
  }

  Future<void> verifyOTP() async {
    if (otpCode.length != 6) {
      Get.snackbar('Error', 'Please enter a valid OTP!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      // Get deviceId early and log it
      String? deviceId;
      if (!kIsWeb) {
        deviceId = await DeviceUtils.getDeviceId();
      }
      debugPrint('verifyOTP -> deviceId: $deviceId');

      // If your server requires deviceId (your code does), show message and abort if missing
      if (deviceId == null) {
        Get.snackbar('Error', 'Device id not available. Please restart the app or grant permissions.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        setState(() => isLoading = false);
        return;
      }

      final body = jsonEncode({
        'phone': phoneNumber,
        'otp': otpCode,
        'deviceId': deviceId,
      });

      // call ApiManager but also inspect the raw Response for debugging
      final response = await ApiManager.post('verify-otp', jsonDecode(body));
      debugPrint('verify-otp status: ${response.statusCode} body: ${response.body}');

      // parse and handle responses more verbosely
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true || data['success'] == 1) {
          String token = data['token'];
          String driverId = data['driver']['id'].toString();
          String phone = data['driver']['phone'].toString();

          await box.write('token', token);
          await box.write('driverId', driverId);
          await box.write('phone', phone);

          Get.off(() => HomeScreen());
        } else {
          Get.snackbar('Error', data['message'] ?? 'OTP verification failed',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        // show server message if present
        try {
          final err = jsonDecode(response.body);
          Get.snackbar('Error', err['message'] ?? 'OTP failed (${response.statusCode})',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } catch (e) {
          Get.snackbar('Error', 'OTP failed (${response.statusCode})',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      }
    } catch (e) {
      debugPrint('verifyOTP exception: $e');
      Get.snackbar('Error', 'OTP verification failed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkDriverExistence() async {
    try {
      var response = await ApiManager.get('drivers/verify-phone?phone=$phoneNumber');
      var data = jsonDecode(response.body);
      if (data['exists'] == true) {
        Get.off(() => HomeScreen());
      } else {
        Get.snackbar('Info', 'Driver not found. Please contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check driver existence.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void resendOTP() async {
    if (!isResendEnabled) return;
    try {
      await ApiManager.post('resend-otp', {'phone': phoneNumber});
      Get.snackbar('Info', 'OTP Resent Successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
      startResendCountdown();
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: Colors.blueAccent[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Enter the OTP sent to your mobile number',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 20),
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: otpCode,
              decoration: BoxLooseDecoration(
                strokeColorBuilder:
                FixedColorBuilder(Colors.blueAccent[700]!),
                bgColorBuilder: FixedColorBuilder(Colors.white),
                radius: Radius.circular(12),
              ),
              onCodeChanged: (code) => setState(() => otpCode = code ?? ''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Verify OTP', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isResendEnabled ? resendOTP : null,
              child: Text(
                isResendEnabled ? 'Resend OTP' : 'Resend in $resendCountdown s',
                style: TextStyle(color: Colors.blueAccent[700], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
