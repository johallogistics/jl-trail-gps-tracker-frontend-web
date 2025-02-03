import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  final box = GetStorage();

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
      Get.snackbar('Success'.tr, 'OTP Verified Successfully!'.tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

      // Navigate to Home Screen
      Get.off(() => const HomeScreen());
    } else {
      Get.snackbar('Error'.tr, 'Please enter a valid OTP!'.tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void resendOTP() {
    // TODO: Trigger OTP resend API
    Get.snackbar('Info'.tr, 'OTP Resent Successfully!'.tr,
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
        title: Text('OTP Verification'.tr),
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
              if (langCode != null) {
                box.write('selectedLanguage', langCode); // Save selected language globally
                print("Language changed to: $langCode.... ${box.read('selectedLanguage')}");
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Enter the OTP sent to your mobile number'.tr,
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
              child: Text('Verify OTP'.tr),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isResendEnabled ? resendOTP : null,
              child: Text(isResendEnabled ? 'Resend OTP'.tr : 'Resend in $resendCountdown s'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
