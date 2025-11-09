// lib/screens/driver_add_popup.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin/driver_management_controller.dart';
import '../../../models/admin/driver_model.dart';
import '../../../utils/image_upload_service.dart';

class DriverAddPopup extends StatelessWidget {
  final DriverController controller = Get.put(DriverController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // --- New: expiry date handling ---
  final TextEditingController expiryTextController = TextEditingController();
  final Rx<DateTime?> licenseExpiry = Rx<DateTime?>(null);
  final DateFormat _df = DateFormat('dd MMM yyyy');

  List<String>? urls;

  DriverAddPopup({super.key});

  Future<void> _pickExpiryDate(BuildContext context) async {
    final today = DateTime.now();
    final initial = licenseExpiry.value ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(today.year + 15, 12, 31),
      helpText: 'Select Driving License Expiry Date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      licenseExpiry.value = DateTime(picked.year, picked.month, picked.day);
      expiryTextController.text = _df.format(licenseExpiry.value!);
    }
  }

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

            // --- New: Driving License Expiry Date (read-only with date picker) ---
            const SizedBox(height: 12),
            Obx(
                  () => TextField(
                controller: expiryTextController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Driving License Expiry Date',
                  hintText: 'Select date',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (licenseExpiry.value != null)
                        IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            licenseExpiry.value = null;
                            expiryTextController.clear();
                          },
                        ),
                      IconButton(
                        tooltip: 'Pick date',
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
          ],
        ),
      ),

      actions: [
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            urls = await uploadMultipleToBackblaze();
            // ignore: avoid_print
            print("URLS::: $urls");
          },
          child: const Text('Upload Files'),
        ),
        Obx(() => ElevatedButton(
          onPressed: () async {
            final driver = Driver(
              name: nameController.text.trim(),
              phone: phoneController.text.trim(),
              employeeId: employeeIdController.text.trim(),
              address: addressController.text.trim(),
              locationEnabled: false,
              proofDocs: urls ?? [],
              drivingLicenseExpiryDate: licenseExpiry.value, // <-- NEW
            );
            await controller.addDriver(driver);
          },
          child: controller.isLoading.value
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
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
