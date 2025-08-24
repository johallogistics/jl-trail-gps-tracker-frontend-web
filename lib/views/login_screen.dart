import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/api_manager.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  String phoneNumber;
  LoginScreen({super.key, required this.phoneNumber});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with CodeAutoFill {
  String otpCode = "";
  bool isResendEnabled = false;
  int resendCountdown = 30;
  final box = GetStorage();
  late String phoneNumber; // Replace with actual phone number

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
      otpCode = code!;
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
    if (otpCode.length == 6) {
      try {
        var response = await ApiManager.post('verify-otp', {'phone': phoneNumber, 'otp': otpCode});
        var data = jsonDecode(response.body);

        if (data['success'] == true || data['success'] == 1) {
          String token = data['token'];
          String driverId = "23b1a22b-7f62-4659-9e97-9709f385d8a3" ?? data['driver']['id'].toString(); // ✅ correct way
          String phone = "+918925450309" ?? data['driver']['phone'].toString(); // ✅ correct way

          // ✅ Save token and driverId in GetStorage
          final box = GetStorage();
          await box.write('token', token);
          await box.write('driverId', driverId);
          await box.write('phone', phone);


          Get.off(() => HomeScreen());
        } else {
          Get.snackbar('Error', data['message'] ?? 'OTP verification failed',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar('Error', 'OTP verification failed!',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar('Error', 'Please enter a valid OTP!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }



  Future<void> checkDriverExistence() async {
    try {
      var response = await ApiManager.get('drivers/verify-phone?phone=$phoneNumber');
      var data = jsonDecode(response.body);
      if (data['exists']) {
        Get.off(() => HomeScreen());
      } else {
        Get.snackbar('Info', 'Driver not found. Please contact support.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check driver existence.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void resendOTP() async {
    try {
      await ApiManager.post('resend-otp', {'phone': phoneNumber});
      Get.snackbar('Info', 'OTP Resent Successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue, colorText: Colors.white);
      startResendCountdown();
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
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
      backgroundColor: Colors.blue[50], // ✅ Light blue background
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: Colors.blueAccent[700], // ✅ Deep blue AppBar
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey[800]),
            ),
            const SizedBox(height: 20),
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: otpCode,
              decoration: BoxLooseDecoration(
                strokeColorBuilder: FixedColorBuilder(Colors.blueAccent[700]!),
                bgColorBuilder: FixedColorBuilder(Colors.white),
                radius: Radius.circular(12),
              ),
              onCodeChanged: (code) => setState(() => otpCode = code ?? ''),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700], // ✅ Blue button
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Verify OTP', style: TextStyle(fontSize: 16)),
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
