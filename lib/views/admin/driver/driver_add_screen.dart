// lib/screens/driver_add_popup.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/driver_management_controller.dart';
import '../../../models/admin/driver_model.dart';
import '../../../utils/image_upload_service.dart';

class DriverAddPopup extends StatelessWidget {
  final DriverController controller = Get.put(DriverController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  List<String>? urls;

  DriverAddPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Driver'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: employeeIdController,
              decoration: const InputDecoration(labelText: 'Employee ID'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
      ),

      actions: [
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            urls = await uploadMultipleMediaAndSendUrls();
            print("URLS::: $urls");
          },
          child: const Text('Upload Files'),
        ),
        Obx(() => ElevatedButton(
          onPressed: () async {
            final driver = Driver(
              name: nameController.text,
              phone: phoneController.text,
              employeeId: employeeIdController.text,
              address: addressController.text, locationEnabled: false, proofDocs: urls ?? [],
            );
            await controller.addDriver(driver);
          },
          child: controller.isLoading.value
              ? const CircularProgressIndicator()
              : const Text('Add'),
        )),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
