import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Language Translations

// Form Controller
class FormController extends GetxController {
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final masterDriverNameController = TextEditingController();
  final empCodeController = TextEditingController();
  final mobileNoController = TextEditingController();
  final customerDriverNameController = TextEditingController();
  final customerMobileNoController = TextEditingController();
  final licenseNoController = TextEditingController();

  var vehicleDetails = <Map<String, dynamic>>[].obs;
  var competitorReference = <String, TextEditingController>{}.obs;
  var selectedFieldsForCompetitor = <String, bool>{}.obs;

  void addVehicleDetail() {
    var newVehicle = {
      'vehicleRegNo'.tr: TextEditingController(),
      'brand'.tr: TextEditingController(),
      'chassisNo'.tr: TextEditingController(),
      'vehicleModel'.tr: TextEditingController(),
      'wheelBase'.tr: TextEditingController(),
      'atsType'.tr: TextEditingController(),
      'emission'.tr: TextEditingController(),
      'tyreBrand'.tr: TextEditingController(),
      'application'.tr: TextEditingController(),
      'gvwCarried'.tr: TextEditingController(),
      'tripStartDate'.tr: TextEditingController(),
      'startOdo'.tr: TextEditingController(),
      'tripFinishDate'.tr: TextEditingController(),
      'endOdo'.tr: TextEditingController(),
      'startPlace'.tr: TextEditingController(),
      'endPlace'.tr: TextEditingController(),
      'totalTrailKms'.tr: TextEditingController(),
      'fuelConsumed'.tr: TextEditingController(),
      'adBlueConsumedCluster'.tr: TextEditingController(),
      'didRegenerationHappen': false.obs,
      'leadDistance'.tr: TextEditingController(),
      'drivingSpeed'.tr: TextEditingController(),
      'actualFeInBB'.tr: TextEditingController(),
    }
    ;
    vehicleDetails.add(newVehicle);
  }
}
// Form Screen
class FormScreen extends StatelessWidget {
  final FormController controller = Get.put(FormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('trip_form'.tr),
      ),
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
                children: [
                  for (var vehicle in controller.vehicleDetails)
                    Column(
                      children: vehicle.entries.map((entry) {
                        if (entry.key != 'didRegenerationHappen') {
                          return buildTextField(entry.key.tr, entry.value);
                        }
                        return Obx(() => CheckboxListTile(
                          title: Text('did_regeneration'.tr),
                          value: vehicle['didRegenerationHappen'].value,
                          onChanged: (val) {
                            vehicle['didRegenerationHappen'].value = val ?? false;
                          },
                        ));
                      }).toList(),
                    ),
                ],
              )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.addVehicleDetail,
                child: Text('add_vehicle'.tr),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print("Form Submitted");
                },
                child: Text('submit'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
