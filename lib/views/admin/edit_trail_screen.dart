import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../models/consolidated_form_submission_model.dart';
import '../../repositories/consolidated_form_repository.dart';

class EditTrailScreen extends StatelessWidget {
  final FormSubmissionModel trail;
  final AdminController controller = Get.find<AdminController>();

  EditTrailScreen({super.key, required this.trail});

  final _formKey = GlobalKey<FormState>();

  Widget _buildStyledTextFormField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = trail.vehicleDetails.isNotEmpty
        ? trail.vehicleDetails[0]
        : VehicleDetail.fromJson({});

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Trail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildStyledTextFormField(
                label: 'Location',
                controller: TextEditingController(text: trail.location)
                  ..addListener(() => trail.location = trail.location),
              ),
              _buildStyledTextFormField(
                label: 'Master Driver',
                controller: TextEditingController(text: trail.masterDriverName)
                  ..addListener(() => trail.masterDriverName = trail.masterDriverName),
              ),
              _buildStyledTextFormField(label: 'Vehicle Reg No', controller: vehicle.vehicleRegNo),
              _buildStyledTextFormField(label: 'Brand', controller: vehicle.brand),
              _buildStyledTextFormField(label: 'Chassis No', controller: vehicle.chassisNo),
              _buildStyledTextFormField(label: 'Model', controller: vehicle.vehicleModel),
              _buildStyledTextFormField(label: 'Wheel Base', controller: vehicle.wheelBase),
              _buildStyledTextFormField(label: 'ATS Type', controller: vehicle.atsType),
              _buildStyledTextFormField(label: 'Emission', controller: vehicle.emission),
              _buildStyledTextFormField(label: 'Tyre Brand', controller: vehicle.tyreBrand),
              _buildStyledTextFormField(label: 'Application', controller: vehicle.application),
              _buildStyledTextFormField(label: 'GVW Carried', controller: vehicle.gvwCarried),
              _buildStyledTextFormField(label: 'Trip Start Date', controller: vehicle.tripStartDate),
              _buildStyledTextFormField(label: 'Start Odo', controller: vehicle.startOdo),
              _buildStyledTextFormField(label: 'Trip Finish Date', controller: vehicle.tripFinishDate),
              _buildStyledTextFormField(label: 'End Odo', controller: vehicle.endOdo),
              _buildStyledTextFormField(label: 'Start Place', controller: vehicle.startPlace),
              _buildStyledTextFormField(label: 'End Place', controller: vehicle.endPlace),
              _buildStyledTextFormField(label: 'Total Trail KMs', controller: vehicle.totalTrailKms),
              _buildStyledTextFormField(label: 'Fuel Consumed', controller: vehicle.fuelConsumed),
              _buildStyledTextFormField(label: 'AdBlue Consumed Cluster', controller: vehicle.adBlueConsumedCluster),
              Obx(() => CheckboxListTile(
                title: const Text('Did Regeneration Happen?'),
                value: vehicle.didRegenerationHappen.value,
                onChanged: (val) => vehicle.didRegenerationHappen.value = val ?? false,
              )),
              _buildStyledTextFormField(label: 'Lead Distance', controller: vehicle.leadDistance),
              _buildStyledTextFormField(label: 'Driving Speed', controller: vehicle.drivingSpeed),
              _buildStyledTextFormField(label: 'Actual FE in BB', controller: vehicle.actualFeInBB),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      Get.snackbar("Updating", "Please wait...", showProgressIndicator: true);
                      final updated = await FormRepository.updateTrail(trail.id!, trail.toJson());
                      if (updated != null) {
                        controller.fetchTrails();
                        Get.back();
                        Get.snackbar("Success", "Trail updated successfully");
                      } else {
                        Get.snackbar("Error", "Failed to update trail");
                      }
                    } catch (e) {
                      Get.snackbar("Error", "Update failed: $e");
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
