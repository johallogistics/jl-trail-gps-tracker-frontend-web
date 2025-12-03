import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            """
PRIVACY POLICY

Your privacy matters to us. This admin panel collects login information to authenticate access. 

We do not share personal data with third parties except where required by law.

Data we collect:
• Login timestamp
• Device/IP (logged for security)

How we use the data:
• Secure access to app
• Track unauthorized login attempts
• Improve system reliability

If you have questions, contact: johallogistics@gmail.com

""",
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
