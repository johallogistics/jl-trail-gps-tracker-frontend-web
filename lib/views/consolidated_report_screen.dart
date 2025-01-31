import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void onInit() {
    super.onInit();
    // addVehicleDetail(); // Ensure at least one set of vehicle fields is present
  }

  void addVehicleDetail() {
    var newVehicle = {
      'vehicleRegNo': TextEditingController(),
      'brand': TextEditingController(),
      'chassisNo': TextEditingController(),
      'vehicleModel': TextEditingController(),
      'wheelBase': TextEditingController(),
      'atsType': TextEditingController(),
      'emission': TextEditingController(),
      'tyreBrand': TextEditingController(),
      'application': TextEditingController(),
      'gvwCarried': TextEditingController(),
      'tripStartDate': TextEditingController(),
      'startOdo': TextEditingController(),
      'tripFinishDate': TextEditingController(),
      'endOdo': TextEditingController(),
      'startPlace': TextEditingController(),
      'endPlace': TextEditingController(),
      'totalTrailKms': TextEditingController(),
      'fuelConsumed': TextEditingController(),
      'adBlueConsumedCluster': TextEditingController(),
      'didRegenerationHappen': false.obs,
      'leadDistance': TextEditingController(),
      'drivingSpeed': TextEditingController(),
      'actualFeInBB': TextEditingController(),
    };
    vehicleDetails.add(newVehicle);
  }

  void updateCompetitorReference() {
    competitorReference.clear();
    if (vehicleDetails.isNotEmpty) {
      selectedFieldsForCompetitor.forEach((key, value) {
        if (value) {
          competitorReference[key] = TextEditingController(text: vehicleDetails[0][key].text);
        }
      });
    }
  }

  @override
  void onClose() {
    locationController.dispose();
    dateController.dispose();
    masterDriverNameController.dispose();
    empCodeController.dispose();
    mobileNoController.dispose();
    customerDriverNameController.dispose();
    customerMobileNoController.dispose();
    licenseNoController.dispose();

    for (var vehicle in vehicleDetails) {
      vehicle.forEach((key, value) {
        if (value is TextEditingController) value.dispose();
      });
    }

    super.onClose();
  }
}

class FormScreen extends StatelessWidget {
  final FormController controller = Get.put(FormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trip Form")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Location", controller.locationController),
              buildTextField("Date", controller.dateController),
              buildTextField("Master Driver Name", controller.masterDriverNameController),
              buildTextField("Emp Code", controller.empCodeController),
              buildTextField("Mobile No", controller.mobileNoController),
              buildTextField("Customer Driver Name", controller.customerDriverNameController),
              buildTextField("Customer Mobile No", controller.customerMobileNoController),
              buildTextField("License No", controller.licenseNoController),
              SizedBox(height: 20),
              Text("Vehicle Details"),
              Obx(() => Column(
                children: [
                  for (var vehicle in controller.vehicleDetails)
                    Column(
                      children: vehicle.entries.map((entry) {
                        if (entry.key != 'didRegenerationHappen') {
                          return Row(
                            children: [
                              Expanded(child: buildTextField(entry.key, entry.value)),
                              Obx(() => Checkbox(
                                value: controller.selectedFieldsForCompetitor[entry.key] ?? false,
                                onChanged: (val) {
                                  controller.selectedFieldsForCompetitor[entry.key] = val ?? false;
                                  controller.updateCompetitorReference();
                                },
                              )),
                            ],
                          );
                        }
                        return Obx(() => CheckboxListTile(
                          title: Text("Did Regeneration happen during trip?"),
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
              Text("Competitor Reference"),
              Obx(() => Column(
                children: controller.competitorReference.entries
                    .map((entry) => buildTextField(entry.key, entry.value))
                    .toList(),
              )),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.addVehicleDetail();
                },
                child: Text("Add Vehicle Details"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print("Form Submitted");
                },
                child: Text("Submit"),
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
