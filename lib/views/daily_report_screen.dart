// daily_report_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import '../models/shift_log_model.dart';
import 'daily_report_review_screen.dart';
import 'dart:typed_data' as td;

class DailyReportController extends GetxController {
  // Timing & vehicle fields you already had
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

  // Employee details as form fields (previously read-only)
  final employeeNameController = TextEditingController();
  final employeePhoneController = TextEditingController();
  final employeeCodeController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final inchargeNameController = TextEditingController();
  final inchargePhoneController = TextEditingController();

  // Default date string
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void onClose() {
    // dispose controllers if needed
    shiftController.dispose();
    otHoursController.dispose();
    vehicleModelController.dispose();
    regNoController.dispose();
    inTimeController.dispose();
    outTimeController.dispose();
    workingHoursController.dispose();
    startingKmController.dispose();
    endingKmController.dispose();
    totalKmController.dispose();
    fromPlaceController.dispose();
    toPlaceController.dispose();
    fuelAvgController.dispose();
    coDriverNameController.dispose();
    coDriverPhoneController.dispose();

    employeeNameController.dispose();
    employeePhoneController.dispose();
    employeeCodeController.dispose();
    monthController.dispose();
    yearController.dispose();
    inchargeNameController.dispose();
    inchargePhoneController.dispose();
    super.onClose();
  }
}

class DailyReportScreen extends StatelessWidget {
  final Map<String, String> employeeData;
  final DailyReportController controller = Get.put(DailyReportController());

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  DailyReportScreen({super.key, required this.employeeData}) {
    // Pre-fill employee fields from the provided employeeData map
    controller.employeeNameController.text = employeeData['name'] ?? '';
    controller.employeePhoneController.text = employeeData['phone'] ?? '';
    controller.employeeCodeController.text = employeeData['code'] ?? '';
    controller.monthController.text = employeeData['month'] ?? '';
    controller.yearController.text = employeeData['year'] ?? '';
    controller.inchargeNameController.text = employeeData['inchargeName'] ?? '';
    controller.inchargePhoneController.text = employeeData['inchargePhone'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Soft blue background
      appBar: AppBar(
        title: Text('daily_report_form'.tr),
        backgroundColor: Colors.blueAccent[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Employee details now as editable form
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
            // Replace _buildInfoRow with input fields bound to controller
            buildTextField('employee_name'.tr, controller.employeeNameController),
            buildTextField('employee_phone'.tr, controller.employeePhoneController),
            buildTextField('employee_code'.tr, controller.employeeCodeController),
            Row(
              children: [
                Expanded(child: buildTextField('month'.tr, controller.monthController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField('year'.tr, controller.yearController)),
              ],
            ),
            buildTextField('incharge_name'.tr, controller.inchargeNameController),
            buildTextField('incharge_phone'.tr, controller.inchargePhoneController),
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
            // date readonly
            buildTextField('date'.tr, TextEditingController(text: controller.date), enabled: false),
            buildTextField('shift'.tr, controller.shiftController),
            buildTextField('ot_hours'.tr, controller.otHoursController),
            buildTextField('vehicle_model'.tr, controller.vehicleModelController),
            buildTextField('vehicle_reg_no'.tr, controller.regNoController),
            Row(
              children: [
                Expanded(child: buildTextField('in_time'.tr, controller.inTimeController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField('out_time'.tr, controller.outTimeController)),
              ],
            ),
            buildTextField('working_hours'.tr, controller.workingHoursController),
            Row(
              children: [
                Expanded(child: buildTextField('starting_km'.tr, controller.startingKmController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField('ending_km'.tr, controller.endingKmController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField('total_km'.tr, controller.totalKmController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: buildTextField('from_place'.tr, controller.fromPlaceController)),
                const SizedBox(width: 12),
                Expanded(child: buildTextField('to_place'.tr, controller.toPlaceController)),
              ],
            ),
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
            width: double.infinity,
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

  Future<void> _saveReportWithSignature(BuildContext context) async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a signature.')),
      );
      return;
    }

    final td.Uint8List? signature = await _signatureController.toPngBytes();
    if (signature == null) return;

    // Build ShiftLog from available fields. For many fields not yet in UI, use sensible defaults.
    final now = DateTime.now();
    // parse ints/doubles where appropriate with fallback
    int _parseInt(String s) {
      try {
        return int.parse(s);
      } catch (_) {
        return 0;
      }
    }

    double _parseDouble(String s) {
      try {
        return double.parse(s);
      } catch (_) {
        return 0.0;
      }
    }

    DateTime _tryParseDateTime(String s) {
      try {
        return DateTime.parse(s);
      } catch (_) {
        return now;
      }
    }

    final shiftLog = ShiftLog(
      // id
      id: null,
      // basic timing
      shift: controller.shiftController.text.trim(),
      otHours: _parseInt(controller.otHoursController.text.trim()),
      inTime: _tryParseDateTime(controller.inTimeController.text.trim()),
      outTime: _tryParseDateTime(controller.outTimeController.text.trim()),
      workingHours: _parseInt(controller.workingHoursController.text.trim()),
      monthYear: '${controller.monthController.text.trim()}-${controller.yearController.text.trim()}',
      // vehicle
      vehicleModel: controller.vehicleModelController.text.trim(),
      regNo: controller.regNoController.text.trim(),
      chassisNo: '', // TODO: map chassis input if you have it
      gvw: 0.0,
      payload: 0.0,
      startingKm: _parseInt(controller.startingKmController.text.trim()),
      endingKm: _parseInt(controller.endingKmController.text.trim()),
      totalKm: _parseInt(controller.totalKmController.text.trim()),
      fuelAvg: _parseDouble(controller.fuelAvgController.text.trim()),
      previousKmpl: 0.0,
      clusterKmpl: 0.0,
      highwaySweetSpotPercent: 0.0,
      normalRoadSweetSpotPercent: 0.0,
      hillsRoadSweetSpotPercent: 0.0,
      trialKMPL: '',
      vehicleOdometerStartingReading: '',
      vehicleOdometerEndingReading: '',
      trialKMS: '',
      trialAllocation: '',
      // trial info
      purposeOfTrial: '',
      reason: '',
      dateOfSale: '',
      trailId: '',
      // location
      fromPlace: controller.fromPlaceController.text.trim(),
      toPlace: controller.toPlaceController.text.trim(),
      presentLocation: '',
      // personnel - map employee inputs here
      employeeName: controller.employeeNameController.text.trim(),
      vecvReportingPerson: '',
      employeePhoneNo: controller.employeePhoneController.text.trim(),
      employeeCode: controller.employeeCodeController.text.trim(),
      dicvInchargeName: controller.inchargeNameController.text.trim(),
      dicvInchargePhoneNo: controller.inchargePhoneController.text.trim(),
      // customer & dealer
      dealerName: '',
      customerName: '',
      customerDriverName: '',
      customerDriverNo: '',
      capitalizedVehicleOrCustomerVehicle: '',
      customerVehicle: '',
      capitalizedVehicle: '',
      vehicleNo: '',
      // driver
      coDriverName: controller.coDriverNameController.text.trim(),
      coDriverPhoneNo: controller.coDriverPhoneController.text.trim(),
      driverStatus: '',
      // media
      imageVideoUrls: const [],
      inchargeSign: 'embedded_as_base64_or_path_placeholder', // you probably want to upload bytes and store URL
      // timestamps
      createdAt: now,
      updatedAt: now,
    );

    // For debug: print resulting JSON
    // ignore: avoid_print
    print('ShiftLog JSON: ${shiftLog.toJson()}');

    // TODO: Upload signature bytes to server or convert to base64 and include in shiftLog.inchargeSign
    // Example: final b64 = base64Encode(signature);

    // Navigate to review screen. NOTE: update DailyReportReviewScreen to accept a ShiftLog param if needed.
    Get.to(
          () => DailyReportReviewScreen(
        employeeData: employeeData,
        signature: signature,
        shiftLog: shiftLog,
      ),
    );

    // Alternatively, if you prefer to send via arguments:
    // Get.toNamed('/dailyReportReview', arguments: {'employeeData': employeeData, 'signature': signature, 'shiftLog': shiftLog});
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

  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(color: Colors.blueAccent[700], fontSize: 16),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.bold),
          filled: true,
          fillColor: enabled ? Colors.blue[50] : Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
      ),
    );
  }
}
