// lib/screens/edit_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin/driver_management_controller.dart';
import '../../../models/admin/driver_model.dart';
import '../../../utils/image_upload_service.dart'; // add the function below to this helper

class EditDriverScreen extends StatelessWidget {
  final Driver driver;
  final DriverController controller = Get.put(DriverController());
  List<String>? urls;

  EditDriverScreen({super.key, required this.driver});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final employeeIdController = TextEditingController();
  final addressController = TextEditingController();
  final expiryDateController = TextEditingController();
  final Rx<DateTime?> licenseExpiry = Rx<DateTime?>(null);

  final DateFormat _df = DateFormat('dd MMM yyyy');

  Future<void> _pickExpiryDate(BuildContext context) async {
    final today = DateTime.now();
    final initial = licenseExpiry.value ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(today.year + 15, 12, 31),
      helpText: 'Select Driving License Expiry Date',
    );

    if (picked != null) {
      licenseExpiry.value = DateTime(picked.year, picked.month, picked.day);
      expiryDateController.text = _df.format(licenseExpiry.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = driver.name;
    phoneController.text = driver.phone;
    employeeIdController.text = driver.employeeId;
    addressController.text = driver.address;

    if (driver.drivingLicenseExpiryDate != null) {
      licenseExpiry.value = driver.drivingLicenseExpiryDate;
      expiryDateController.text = _df.format(driver.drivingLicenseExpiryDate!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Driver')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: employeeIdController,
              decoration: const InputDecoration(labelText: 'Employee ID'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            Obx(
                  () => TextField(
                controller: expiryDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Driving License Expiry Date',
                  hintText: 'Select date',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (licenseExpiry.value != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            licenseExpiry.value = null;
                            expiryDateController.clear();
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () => _pickExpiryDate(context),
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _pickExpiryDate(context),
              ),
            ),
            const SizedBox(height: 20),

            // Upload and attach directly to this driver
            ElevatedButton(
              onPressed: () async {
                urls = await uploadMultipleViaProxyForDriver(
                  driverId: driver.id!,      // 👈 attaches immediately
                  folder: 'drivers',
                  // documentTypes: ['AADHAAR', 'DL'], // optional labels per file
                );
                // ignore: avoid_print
                print("Uploaded URLs: $urls");
              },
              child: const Text('Upload Files'),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedDriver = Driver(
                  id: driver.id,
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  employeeId: employeeIdController.text.trim(),
                  address: addressController.text.trim(),
                  locationEnabled: driver.locationEnabled,
                  proofDocs: urls ?? driver.proofDocs, // keep existing + new if you want to merge
                  drivingLicenseExpiryDate: licenseExpiry.value,
                );

                await controller.updateDriver(driver.id!, updatedDriver);
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
