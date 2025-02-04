import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/consolidated_form_controller.dart';

class FormScreen extends StatelessWidget {
  final FormController controller = Get.put(FormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('trip_form'.tr)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField('location'.tr, controller.locationController),
              buildTextField('date'.tr, controller.dateController),
              buildTextField('master_driver_name'.tr, controller.masterDriverNameController),
              buildTextField('emp_code'.tr, controller.empCodeController),
              buildTextField('mobile_no'.tr, controller.mobileNoController),
              buildTextField('customer_driver_name'.tr, controller.customerDriverNameController),
              buildTextField('customer_mobile_no'.tr, controller.customerMobileNoController),
              buildTextField('license_no'.tr, controller.licenseNoController),
              SizedBox(height: 20),

              Text('vehicle_details'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Obx(() => Column(
                children: controller.vehicleDetails.map((vehicle) {
                  return Column(
                    children: [
                      buildTextField('vehicleRegNo'.tr, vehicle.vehicleRegNo),
                      buildTextField('brand'.tr, vehicle.brand),
                      buildTextField('chassisNo'.tr, vehicle.chassisNo),
                      buildTextField('vehicleModel'.tr, vehicle.vehicleModel),
                      buildTextField('wheelBase'.tr, vehicle.wheelBase),
                      buildTextField('atsType'.tr, vehicle.atsType),
                      buildTextField('emission'.tr, vehicle.emission),
                      buildTextField('tyreBrand'.tr, vehicle.tyreBrand),
                      buildTextField('application'.tr, vehicle.application),
                      buildTextField('gvwCarried'.tr, vehicle.gvwCarried),
                      buildTextField('tripStartDate'.tr, vehicle.tripStartDate),
                      buildTextField('startOdo'.tr, vehicle.startOdo),
                      buildTextField('tripFinishDate'.tr, vehicle.tripFinishDate),
                      buildTextField('endOdo'.tr, vehicle.endOdo),
                      buildTextField('startPlace'.tr, vehicle.startPlace),
                      buildTextField('endPlace'.tr, vehicle.endPlace),
                      buildTextField('totalTrailKms'.tr, vehicle.totalTrailKms),
                      buildTextField('fuelConsumed'.tr, vehicle.fuelConsumed),
                      buildTextField('adBlueConsumedCluster'.tr, vehicle.adBlueConsumedCluster),
                      Obx(() => CheckboxListTile(
                        title: Text('did_regeneration'.tr),
                        value: vehicle.didRegenerationHappen.value,
                        onChanged: (val) {
                          vehicle.didRegenerationHappen.value = val ?? false;
                        },
                      )),
                      buildTextField('leadDistance'.tr, vehicle.leadDistance),
                      buildTextField('drivingSpeed'.tr, vehicle.drivingSpeed),
                      buildTextField('actualFeInBB'.tr, vehicle.actualFeInBB),
                    ],
                  );
                }).toList(),
              )),

              SizedBox(height: 20),
              Text('competitor_data'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Obx(() => Column(
                children: controller.competitorData.map((competitorVehicle) {
                  return Column(
                    children: [
                      buildCopyCheckbox('vehicleRegNo', competitorVehicle.vehicleRegNo, controller.vehicleDetails[0].vehicleRegNo),
                      buildCopyCheckbox('brand', competitorVehicle.brand, controller.vehicleDetails[0].brand),
                      buildCopyCheckbox('chassisNo', competitorVehicle.chassisNo, controller.vehicleDetails[0].chassisNo),
                      buildCopyCheckbox('vehicleModel', competitorVehicle.vehicleModel, controller.vehicleDetails[0].vehicleModel),
                      buildCopyCheckbox('wheelBase', competitorVehicle.wheelBase, controller.vehicleDetails[0].wheelBase),
                      buildCopyCheckbox('atsType', competitorVehicle.atsType, controller.vehicleDetails[0].atsType),
                      buildCopyCheckbox('emission', competitorVehicle.emission, controller.vehicleDetails[0].emission),
                      buildCopyCheckbox('tyreBrand', competitorVehicle.tyreBrand, controller.vehicleDetails[0].tyreBrand),
                      buildCopyCheckbox('application', competitorVehicle.application, controller.vehicleDetails[0].application),
                      buildCopyCheckbox('gvwCarried', competitorVehicle.gvwCarried, controller.vehicleDetails[0].gvwCarried),
                      buildCopyCheckbox('tripStartDate', competitorVehicle.tripStartDate, controller.vehicleDetails[0].tripStartDate),
                      buildCopyCheckbox('startOdo', competitorVehicle.startOdo, controller.vehicleDetails[0].startOdo),
                      buildCopyCheckbox('tripFinishDate', competitorVehicle.tripFinishDate, controller.vehicleDetails[0].tripFinishDate),
                      buildCopyCheckbox('endOdo', competitorVehicle.endOdo, controller.vehicleDetails[0].endOdo),
                      buildCopyCheckbox('startPlace', competitorVehicle.startPlace, controller.vehicleDetails[0].startPlace),
                      buildCopyCheckbox('endPlace', competitorVehicle.endPlace, controller.vehicleDetails[0].endPlace),
                      buildCopyCheckbox('totalTrailKms', competitorVehicle.totalTrailKms, controller.vehicleDetails[0].totalTrailKms),
                      buildCopyCheckbox('fuelConsumed', competitorVehicle.fuelConsumed, controller.vehicleDetails[0].fuelConsumed),
                      buildCopyCheckbox('adBlueConsumedCluster', competitorVehicle.adBlueConsumedCluster, controller.vehicleDetails[0].adBlueConsumedCluster),
                      buildCopyCheckbox('leadDistance', competitorVehicle.leadDistance, controller.vehicleDetails[0].leadDistance),
                      buildCopyCheckbox('drivingSpeed', competitorVehicle.drivingSpeed, controller.vehicleDetails[0].drivingSpeed),
                      buildCopyCheckbox('actualFeInBB', competitorVehicle.actualFeInBB, controller.vehicleDetails[0].actualFeInBB),
                    ],
                  );
                }).toList(),
              )),

              ElevatedButton(
                onPressed: controller.submitForm,
                child: Text('Submit Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget buildCopyCheckbox(String fieldName, TextEditingController competitorController, TextEditingController vehicleController) {
    RxBool isChecked = false.obs;

    return Obx(() => Row(
      children: [
        Checkbox(
          value: isChecked.value,
          onChanged: (val) {
            isChecked.value = val ?? false;
            competitorController.text = isChecked.value ? vehicleController.text : '';
          },
        ),
        Expanded(child: buildTextField(fieldName.tr, competitorController, readOnly: isChecked.value)),
      ],
    ));
  }

}
