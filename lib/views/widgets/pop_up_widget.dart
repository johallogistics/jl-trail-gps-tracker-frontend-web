import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controllers/admin/admin_home_screen_controller.dart';
import '../../models/consolidated_form_submission_model.dart';
import '../../models/trials_model.dart';

class PopUpWidget extends StatelessWidget {
  PopUpWidget({super.key});

  final AdminController controller = Get.put(AdminController());


  @override
  Widget build(BuildContext context) {
    return _buildPopup();
  }

  Widget _buildPopup() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Obx(() {
        if (controller.selectedTrail.value == null) return SizedBox();
        FormSubmissionModel trail = controller.selectedTrail.value!;
        return Container(
          width: 500,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Vehicle Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ..._buildTextFields(trail),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text("Edit"),
                    onPressed: controller.enableEditing,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text("Save"),
                    onPressed: controller.saveChanges,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.close),
                    label: Text("Close"),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildTextFields(FormSubmissionModel trail) {
    final hasVehicle = trail.vehicleDetails.isNotEmpty;
    final vehicle = hasVehicle ? trail.vehicleDetails[0] : null;

    return [
      _buildTextField("Vehicle Reg No", vehicle?.vehicleRegNo.text ?? "NA"),
      _buildTextField("Vehicle Model", vehicle?.vehicleModel.text ?? "NA"),
      _buildTextField("Brand", vehicle?.brand.text ?? "NA"),
      _buildTextField("Start Odo", vehicle?.startOdo.text ?? "NA"),
      _buildTextField("End Odo", vehicle?.endOdo.text ?? "NA"),
      _buildTextField("Location", trail.location),
      _buildTextField("Master Driver", trail.masterDriverName),
    ];
  }


  Widget _buildTextField(String label, String value) {
    return Obx(() =>
        TextFormField(
          initialValue: value,
          enabled: controller.isEditing.value,
          decoration: InputDecoration(labelText: label),
        ));
  }
}
