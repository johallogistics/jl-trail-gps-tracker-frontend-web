import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'daily_report_review_screen.dart';
import 'dart:typed_data' as td;
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

class DailyReportController extends GetxController {
  final shiftController = TextEditingController();
  final otHoursController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final regNoController = TextEditingController();
  final inTimeController = TextEditingController();
  final outTimeController = TextEditingController();
  final workingHoursController = TextEditingController();
  final startingKmController = TextEditingController();
  final endingKmController = TextEditingController();
  final totalKmController = TextEditingController();
  final fromPlaceController = TextEditingController();
  final toPlaceController = TextEditingController();
  final fuelAvgController = TextEditingController();
  final coDriverNameController = TextEditingController();
  final coDriverPhoneController = TextEditingController();
  final inchargeSignController = TextEditingController();

  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
}

class DailyReportScreen extends StatelessWidget {
  final Map<String, String> employeeData;
  final DailyReportController controller = Get.put(DailyReportController());

  final SignatureController _signatureController = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white);

  DailyReportScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('daily_report_form'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'employee_name'.tr}: ${employeeData['name']}'),
            Text('${'employee_phone'.tr}: ${employeeData['phone']}'),
            Text('${'employee_code'.tr}: ${employeeData['code']}'),
            Text('${'month'.tr}: ${employeeData['month']}'),
            Text('${'year'.tr}: ${employeeData['year']}'),
            Text('${'incharge_name'.tr}: ${employeeData['inchargeName']}'),
            Text('${'incharge_phone'.tr}: ${employeeData['inchargePhone']}'),
            SizedBox(height: 20),
            buildTextField(
                'date'.tr, TextEditingController(text: controller.date),
                enabled: false),
            buildTextField('shift'.tr, controller.shiftController),
            buildTextField('ot_hours'.tr, controller.otHoursController),
            buildTextField(
                'vehicle_model'.tr, controller.vehicleModelController),
            buildTextField('vehicle_reg_no'.tr, controller.regNoController),
            buildTextField('in_time'.tr, controller.inTimeController),
            buildTextField('out_time'.tr, controller.outTimeController),
            buildTextField(
                'working_hours'.tr, controller.workingHoursController),
            buildTextField('starting_km'.tr, controller.startingKmController),
            buildTextField('ending_km'.tr, controller.endingKmController),
            buildTextField('total_km'.tr, controller.totalKmController),
            buildTextField('from_place'.tr, controller.fromPlaceController),
            buildTextField('to_place'.tr, controller.toPlaceController),
            buildTextField('fuel_avg'.tr, controller.fuelAvgController),
            buildTextField(
                'co_driver_name'.tr, controller.coDriverNameController),
            buildTextField(
                'co_driver_phone'.tr, controller.coDriverPhoneController),
            SizedBox(height: 20),
            const Divider(),
            // Signature Pad
            const Text(
              'In-charge Signature:',
              style: TextStyle(fontSize: 18),
            ),
            Signature(
              width: 500,
              height: 150,
              controller: _signatureController,
              backgroundColor: Colors.blue.shade50,
            ),
            SizedBox(height: 20),
            const Divider(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _signatureController.clear();
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed:() => _saveReportWithSignature(context),
                  child: Text('review'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveReportWithSignature(BuildContext context) async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a signature.')),
      );
      return;
    }

    final td.Uint8List? signature = await _signatureController.toPngBytes();
    if (signature == null) return;

    // Navigate to review screen with the signature
    Get.to(() => DailyReportReviewScreen(
      employeeData: employeeData,
      signature: signature, // Pass the signature image
    ));
  }



  Widget buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

}
