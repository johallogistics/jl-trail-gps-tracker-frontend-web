import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data' as td;
import '../controllers/consolidated_form_controller.dart';
import 'review_consolidated_report_screen.dart';

class FormScreen extends StatelessWidget {
  final FormController controller = Get.put(FormController());
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 4,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('trip_form'.tr),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionHeader('Personal Details'),
            _buildCard([
              buildTextField('location'.tr, controller.locationController),
              buildTextField('date'.tr, controller.dateController),
              buildTextField('master_driver_name'.tr, controller.masterDriverNameController),
              buildTextField('emp_code'.tr, controller.empCodeController),
              buildTextField('mobile_no'.tr, controller.mobileNoController),
              buildTextField('customer_driver_name'.tr, controller.customerDriverNameController),
              buildTextField('customer_mobile_no'.tr, controller.customerMobileNoController),
              buildTextField('license_no'.tr, controller.licenseNoController),
            ]),

            _buildSectionHeader('Vehicle Details'),
            Obx(() => Column(
              children: controller.vehicleDetails.map((vehicle) => _buildCard([
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
                  onChanged: (val) => vehicle.didRegenerationHappen.value = val ?? false,
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                )),
                buildTextField('leadDistance'.tr, vehicle.leadDistance),
                buildTextField('drivingSpeed'.tr, vehicle.drivingSpeed),
                buildTextField('actualFeInBB'.tr, vehicle.actualFeInBB),
              ])).toList(),
            )),

            _buildSectionHeader('Competitor Data'),
            Obx(() => Column(
              children: controller.competitorData.map((competitorVehicle) => _buildCard([
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
              ])).toList(),
            )),

            _buildSectionHeader('Customer Signature'),
            _buildSignatureBox(),

            const SizedBox(height: 20),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSignatureBox() {
    return _buildCard([
      Signature(
        width: double.infinity,
        height: 150,
        controller: _signatureController,
        backgroundColor: Colors.blue.shade50,
      ),
      TextButton(
        onPressed: () => _signatureController.clear(),
        child: const Text('Clear Signature', style: TextStyle(color: Colors.red)),
      )
    ]);
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _saveReportWithSignature(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Review Form', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(color: Colors.blueAccent[700], fontSize: 16),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.bold),
          filled: true,
          fillColor: Colors.blue[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
      ),
    );
  }

  void _saveReportWithSignature(BuildContext context) async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a signature.')));
      return;
    }
    final td.Uint8List? signature = await _signatureController.toPngBytes();
    if (signature == null) return;
    Get.to(() => ReviewFormScreen(signature: signature));
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
          activeColor: Colors.blueAccent,
          checkColor: Colors.white,
        ),
        Expanded(child: buildTextField(fieldName.tr, competitorController, readOnly: isChecked.value)),
      ],
    ));
  }
}
