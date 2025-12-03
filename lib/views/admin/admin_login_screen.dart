import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/admin_login_controller.dart';
import 'privacy_policy_screen.dart';   // ✅ ADD THIS

class AdminLoginScreen extends StatelessWidget {
  final AdminLoginController controller = Get.find<AdminLoginController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Admin Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent[700],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildStyledTextFormField(
                        label: 'Username',
                        controller: controller.usernameController,
                        validator: (value) =>
                        value!.isEmpty ? 'Username required' : null,
                      ),

                      const SizedBox(height: 16),

                      _buildStyledTextFormField(
                        label: 'Password',
                        controller: controller.passwordController,
                        obscureText: true,
                        validator: (value) =>
                        value!.isEmpty ? 'Password required' : null,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              controller.login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // -----------------------------
                      // ✅ PRIVACY POLICY LINK SECTION
                      // -----------------------------
                      GestureDetector(
                        onTap: () {
                          Get.to(() => PrivacyPolicyScreen());
                        },
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent[700],
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextFormField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      cursorColor: Colors.blueAccent,
      style: TextStyle(
        fontSize: 16,
        color: Colors.blueAccent[700],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent[700],
        ),
        filled: true,
        fillColor: Colors.blue[50],
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}
