import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with CodeAutoFill {
  String otpCode = "";
  bool isResendEnabled = false;
  int resendCountdown = 30;

  @override
  void initState() {
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

  void verifyOTP() {
    if (otpCode.length == 6) {
      // TODO: Verify OTP from the backend
      Get.snackbar('Success', 'OTP Verified Successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

      // Navigate to Home Screen
      Get.off(() => const HomeScreen());
    } else {
      Get.snackbar('Error', 'Please enter a valid OTP!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void resendOTP() {
    // TODO: Trigger OTP resend API
    Get.snackbar('Info', 'OTP Resent Successfully!',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue, colorText: Colors.white);
    startResendCountdown();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter the OTP sent to your mobile number',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            PinFieldAutoFill(
              codeLength: 6,
              currentCode: otpCode,
              decoration: UnderlineDecoration(
                colorBuilder: const FixedColorBuilder(Colors.grey),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onCodeChanged: (code) {
                setState(() => otpCode = code ?? '');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOTP,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text('Verify OTP'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isResendEnabled ? resendOTP : null,
              child: Text(isResendEnabled ? 'Resend OTP' : 'Resend in $resendCountdown s'),
            ),
          ],
        ),
      ),
    );
  }
}
