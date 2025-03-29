import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin/driver_management_controller.dart';
import '../../../models/admin/driver_model.dart';

class EditDriverScreen extends StatelessWidget {
  final Driver driver;
  final DriverController controller = Get.put(DriverController());

  EditDriverScreen({required this.driver});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final employeeIdController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = driver.name;
    phoneController.text = driver.phone;
    employeeIdController.text = driver.employeeId;
    addressController.text = driver.address;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Driver')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: employeeIdController, decoration: const InputDecoration(labelText: 'Employee ID')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedDriver = Driver(
                  id: driver.id,
                  name: nameController.text,
                  phone: phoneController.text,
                  employeeId: employeeIdController.text,
                  address: addressController.text,
                );
                print("Driver Data:: $updatedDriver");
                controller.updateDriver(driver.id!, updatedDriver);
                Get.back();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
