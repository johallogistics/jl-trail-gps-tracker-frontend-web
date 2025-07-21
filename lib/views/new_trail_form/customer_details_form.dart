import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/new_trail_controller.dart';

class CustomerDetailsForm extends StatelessWidget {
  final controller = Get.find<TrialFormController>();

  CustomerDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool wide = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              runSpacing: 16,
              spacing: 16,
              children: [
                _buildTextField("Customer Name", "customerName"),
                _buildNumberField("Expected FE", "customerExpectedFe"),
                _buildNumberField("Before Trials FE", "beforeTrialsFe"),
                _buildNumberField("After Trials FE", "afterTrialsFe"),
                _buildTextField("Trip Duration", "tripDuration"),
                _buildTextField("Vehicle No", "vehicleNo"),
                _buildDatePicker(context, "Sale Date", "saleDate"),
                _buildTextField("Model", "model"),
                _buildTextField("Application", "application"),
                _buildMultilineField("Customer Verbatim", "customerVerbatim"),
                _buildMultilineField("Trip Route", "tripRoute"),
                _buildMultilineField("Issues Found on Vehicle Check", "issuesFoundOnVehicleCheck"),
                _buildTextField("Road Type", "roadType"),
                _buildDatePicker(context, "Vehicle Check Date", "vehicleCheckDate"),
                _buildMultilineField("Customer Remarks", "customerRemarks"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, String field) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        onChanged: (v) => controller.updateField(field, v),
      ),
    );
  }

  Widget _buildNumberField(String label, String field) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: TextInputType.number,
        onChanged: (v) => controller.updateField(field, double.tryParse(v)),
      ),
    );
  }

  Widget _buildMultilineField(String label, String field) {
    return SizedBox(
      width: 600,
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        maxLines: 3,
        onChanged: (v) => controller.updateField(field, v),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, String field) {
    return SizedBox(
      width: 300,
      child: OutlinedButton(
        child: Obx(() {
          var dateStr = controller.form.value.toJson()[field];
          return Text(dateStr != null ? dateStr.toString().substring(0, 10) : label);
        }),
        onPressed: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.updateField(field, picked.toIso8601String());
          }
        },
      ),
    );
  }
}
