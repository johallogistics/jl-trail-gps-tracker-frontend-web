import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin/admin_login_controller.dart';

class AdminLoginScreen extends StatelessWidget {
  final AdminLoginController controller = Get.find<AdminLoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Admin Login", style: TextStyle(fontSize: 24)),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) =>
                    value!.isEmpty ? 'Username required' : null,
                  ),
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                    value!.isEmpty ? 'Password required' : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.login,
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
