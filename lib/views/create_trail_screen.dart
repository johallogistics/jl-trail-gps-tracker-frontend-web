import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin/admin_home_screen_controller.dart';
import '../models/consolidated_form_submission_model.dart';
import '../models/trials_model.dart';

class CreateTrailScreen extends StatelessWidget {
  final AdminController controller = Get.find();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController vehicleRegNoController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController startOdoController = TextEditingController();
  final TextEditingController endOdoController = TextEditingController();
  final TextEditingController startPlaceController = TextEditingController();
  final TextEditingController endPlaceController = TextEditingController();
  final TextEditingController fuelConsumedController = TextEditingController();
  final TextEditingController tripStartDateController = TextEditingController();
  final TextEditingController tripFinishDateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController masterDriverNameController = TextEditingController();
  final TextEditingController empCodeController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController customerDriverNameController = TextEditingController();
  final TextEditingController customerMobileNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Trail')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: vehicleRegNoController,
                decoration: InputDecoration(labelText: 'Vehicle Reg No'),
              ),
              TextFormField(
                controller: vehicleModelController,
                decoration: InputDecoration(labelText: 'Vehicle Model'),
              ),
              TextFormField(
                controller: brandController,
                decoration: InputDecoration(labelText: 'Brand'),
              ),
              TextFormField(
                controller: startOdoController,
                decoration: InputDecoration(labelText: 'Start Odometer'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: endOdoController,
                decoration: InputDecoration(labelText: 'End Odometer'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: startPlaceController,
                decoration: InputDecoration(labelText: 'Start Place'),
              ),
              TextFormField(
                controller: endPlaceController,
                decoration: InputDecoration(labelText: 'End Place'),
              ),
              TextFormField(
                controller: fuelConsumedController,
                decoration: InputDecoration(labelText: 'Fuel Consumed'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: tripStartDateController,
                decoration: InputDecoration(labelText: 'Trip Start Date (YYYY-MM-DD)'),
              ),
              TextFormField(
                controller: tripFinishDateController,
                decoration: InputDecoration(labelText: 'Trip Finish Date (YYYY-MM-DD)'),
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              TextFormField(
                controller: masterDriverNameController,
                decoration: InputDecoration(labelText: 'Master Driver Name'),
              ),
              TextFormField(
                controller: empCodeController,
                decoration: InputDecoration(labelText: 'Employee Code'),
              ),
              TextFormField(
                controller: mobileNoController,
                decoration: InputDecoration(labelText: 'Mobile No'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: customerDriverNameController,
                decoration: InputDecoration(labelText: 'Customer Driver Name'),
              ),
              TextFormField(
                controller: customerMobileNoController,
                decoration: InputDecoration(labelText: 'Customer Mobile No'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              Obx(() => controller.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    //  FormSubmissionModel formData = FormSubmissionModel(
                    //   location: locationController.text,
                    //   date: dateController.text,
                    //   masterDriverName: masterDriverNameController.text,
                    //   empCode: empCodeController.text,
                    //   mobileNo: mobileNoController.text,
                    //   customerDriverName: customerDriverNameController.text,
                    //   customerMobileNo: customerMobileNoController.text,
                    //   licenseNo: licenseNoController.text,
                    //   vehicleDetails: vehicleDetails.toList(),
                    //   competitorData: competitorData.toList(),
                    // );
                    final newTrail = TrailRequest(
                      vehicleRegNo: vehicleRegNoController.text,
                      vehicleModel: vehicleModelController.text,
                      brand: brandController.text,
                      startOdo: startOdoController.text,
                      endOdo: endOdoController.text,
                      startPlace: startPlaceController.text,
                      endPlace: endPlaceController.text,
                      fuelConsumed: fuelConsumedController.text,
                      tripStartDate: tripStartDateController.text,
                      tripFinishDate: tripFinishDateController.text,
                      location: locationController.text,
                      date: dateController.text,
                      masterDriverName: masterDriverNameController.text,
                      empCode: empCodeController.text,
                      mobileNo: mobileNoController.text,
                      customerDriverName: customerDriverNameController.text,
                      customerMobileNo: customerMobileNoController.text,
                    );
                    bool success = await controller.createTrail(newTrail);
                    if (success) {
                      Get.back();
                      Get.snackbar('Success', 'Trail created successfully');
                    } else {
                      Get.snackbar('Error', 'Failed to create trail');
                    }
                  }
                },
                child: Text('Submit'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
