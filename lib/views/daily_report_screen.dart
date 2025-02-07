import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'daily_report_review_screen.dart';
import 'dart:typed_data' as td;

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

  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
}

class DailyReportScreen extends StatelessWidget {
  final Map<String, String> employeeData;
  final DailyReportController controller = Get.put(DailyReportController());

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  DailyReportScreen({super.key, required this.employeeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // ✅ Soft blue background
      appBar: AppBar(
        title: Text('daily_report_form'.tr),
        backgroundColor: Colors.blueAccent[700], // ✅ Deep blue AppBar
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEmployeeDetailsCard(),
            const SizedBox(height: 20),
            _buildInputFieldsCard(),
            const SizedBox(height: 20),
            _buildSignaturePad(),
            const SizedBox(height: 20),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDetailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('employee_name'.tr, employeeData['name']!),
            _buildInfoRow('employee_phone'.tr, employeeData['phone']!),
            _buildInfoRow('employee_code'.tr, employeeData['code']!),
            _buildInfoRow('month'.tr, employeeData['month']!),
            _buildInfoRow('year'.tr, employeeData['year']!),
            _buildInfoRow('incharge_name'.tr, employeeData['inchargeName']!),
            _buildInfoRow('incharge_phone'.tr, employeeData['inchargePhone']!),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFieldsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(
              'date'.tr,
              TextEditingController(text: controller.date),
              enabled: false,
            ),
            buildTextField('shift'.tr, controller.shiftController),
            buildTextField('ot_hours'.tr, controller.otHoursController),
            buildTextField('vehicle_model'.tr, controller.vehicleModelController),
            buildTextField('vehicle_reg_no'.tr, controller.regNoController),
            buildTextField('in_time'.tr, controller.inTimeController),
            buildTextField('out_time'.tr, controller.outTimeController),
            buildTextField('working_hours'.tr, controller.workingHoursController),
            buildTextField('starting_km'.tr, controller.startingKmController),
            buildTextField('ending_km'.tr, controller.endingKmController),
            buildTextField('total_km'.tr, controller.totalKmController),
            buildTextField('from_place'.tr, controller.fromPlaceController),
            buildTextField('to_place'.tr, controller.toPlaceController),
            buildTextField('fuel_avg'.tr, controller.fuelAvgController),
            buildTextField('co_driver_name'.tr, controller.coDriverNameController),
            buildTextField('co_driver_phone'.tr, controller.coDriverPhoneController),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'In-charge Signature:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Signature(
            width: 500,
            height: 150,
            controller: _signatureController,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildElevatedButton('Clear', Colors.red, () {
          _signatureController.clear();
        }),
        _buildElevatedButton('review'.tr, Colors.blueAccent[700], () {
          _saveReportWithSignature(context);
        }),
      ],
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

    Get.to(() => DailyReportReviewScreen(
      employeeData: employeeData,
      signature: signature,
    ));
  }

  Widget _buildElevatedButton(String text, Color? color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent[700])),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(color: Colors.blueAccent[700], fontSize: 16), // ✅ Blue text
        cursorColor: Colors.blueAccent, // ✅ Blue cursor
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.bold), // ✅ Blue label
          filled: true,
          fillColor: enabled ? Colors.blue[50] : Colors.grey[200], // ✅ Light blue bg when enabled
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // ✅ Rounded border
            borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5), // ✅ Light blue border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2.0), // ✅ Deep blue border on focus
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0), // ✅ Comfortable padding
        ),
      ),
    );
  }

}
