// daily_report_screen.dart
import 'dart:convert';
import 'dart:typed_data' as td;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;

import '../models/shift_log_model.dart';
import 'daily_report_review_screen.dart';

class DailyReportController extends GetxController {
  // Basic timing & vehicle fields
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

  // Employee details
  final employeeNameController = TextEditingController();
  final employeePhoneController = TextEditingController();
  final employeeCodeController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final inchargeNameController = TextEditingController();
  final inchargePhoneController = TextEditingController();

  // Extra fields from shift_logs
  final chassisNoController = TextEditingController();
  final gvwController = TextEditingController();
  final payloadController = TextEditingController();
  final presentLocationController = TextEditingController();
  final previousKmplController = TextEditingController();
  final clusterKmplController = TextEditingController();
  final highwaySweetSpotPercentController = TextEditingController();
  final normalRoadSweetSpotPercentController = TextEditingController();
  final hillsRoadSweetSpotPercentController = TextEditingController();
  final trialKMPLController = TextEditingController();
  final vehicleOdometerStartingReadingController = TextEditingController();
  final vehicleOdometerEndingReadingController = TextEditingController();
  final trialKMSController = TextEditingController();
  final trialAllocationController = TextEditingController();
  final vecvReportingPersonController = TextEditingController();
  final dealerNameController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerDriverNameController = TextEditingController();
  final customerDriverNoController = TextEditingController();
  final capitalizedVehicleOrCustomerVehicleController = TextEditingController();
  final customerVehicleController = TextEditingController();
  final capitalizedVehicleController = TextEditingController();
  final vehicleNoController = TextEditingController();
  final driverStatusController = TextEditingController();
  final purposeOfTrialController = TextEditingController();
  final reasonController = TextEditingController();
  final dateOfSaleController = TextEditingController();
  final trailIdController = TextEditingController();
  final inchargeSignController = TextEditingController();

  // Reactive dropdowns
  final selectedVehicleType = RxnString();
  final selectedPurposeOfTrial = RxnString();

  // Default date string
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();

    // Attach listeners to update total km whenever start or end changes.
    startingKmController.addListener(recalcTotalKm);
    endingKmController.addListener(recalcTotalKm);
  }

  /// Public method to recalculate total km from the starting/ending controllers.
  /// Sets totalKmController.text to max(0, ending - starting).
  void recalcTotalKm() {
    try {
      final s = int.tryParse(startingKmController.text.trim()) ?? 0;
      final e = int.tryParse(endingKmController.text.trim()) ?? 0;
      final diff = e - s;
      final totalValue = diff < 0 ? 0 : diff;
      final currentTotal = int.tryParse(totalKmController.text.trim()) ?? -999999;
      if (currentTotal != totalValue) {
        // update without triggering infinite loops (these controllers don't listen to total)
        totalKmController.text = totalValue.toString();
      }
    } catch (_) {
      // ignore parse errors
    }
  }


  @override
  void onClose() {
    // dispose controllers
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

    chassisNoController.dispose();
    gvwController.dispose();
    payloadController.dispose();
    presentLocationController.dispose();
    previousKmplController.dispose();
    clusterKmplController.dispose();
    highwaySweetSpotPercentController.dispose();
    normalRoadSweetSpotPercentController.dispose();
    hillsRoadSweetSpotPercentController.dispose();
    trialKMPLController.dispose();
    vehicleOdometerStartingReadingController.dispose();
    vehicleOdometerEndingReadingController.dispose();
    trialKMSController.dispose();
    trialAllocationController.dispose();
    vecvReportingPersonController.dispose();
    dealerNameController.dispose();
    customerNameController.dispose();
    customerDriverNameController.dispose();
    customerDriverNoController.dispose();
    capitalizedVehicleOrCustomerVehicleController.dispose();
    customerVehicleController.dispose();
    capitalizedVehicleController.dispose();
    vehicleNoController.dispose();
    driverStatusController.dispose();
    purposeOfTrialController.dispose();
    reasonController.dispose();
    dateOfSaleController.dispose();
    trailIdController.dispose();
    inchargeSignController.dispose();

    super.onClose();
  }
}

class DailyReportScreen extends StatelessWidget {
  final DailyReportController controller = Get.put(DailyReportController());

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Update to your real API base URL if needed
  static const String apiBaseUrl =
      'https://jl-trail-gps-tracker-backend-production.up.railway.app';

  DailyReportScreen({super.key});

  // Responsive helper: if width >= breakpoint, show two columns, else single column
  static const double _twoColumnBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('daily_report_form'.tr),
        backgroundColor: Colors.blueAccent[700],
        elevation: 0,
      ),
      body: LayoutBuilder(builder: (ctx, constraints) {
        final isTwoColumn = constraints.maxWidth >= _twoColumnBreakpoint;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                // limit max width on large screens so form stays readable
                constraints: BoxConstraints(
                    maxWidth: isTwoColumn ? 1100 : constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmployeeDetailsCard(isTwoColumn),
                    const SizedBox(height: 20),
                    _buildInputFieldsCard(isTwoColumn),
                    const SizedBox(height: 20),
                    _buildExtraFieldsCard(isTwoColumn),
                    const SizedBox(height: 20),
                    _buildSignaturePad(),
                    const SizedBox(height: 20),
                    _buildButtons(context),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Builds a row with two fields (responsive): label above each field to ensure visibility
  Widget _twoFieldRow({
    required String label1,
    required TextEditingController controller1,
    TextInputType keyboard1 = TextInputType.text,
    required String label2,
    required TextEditingController controller2,
    TextInputType keyboard2 = TextInputType.text,
    required bool isTwoColumn,
  }) {
    if (!isTwoColumn) {
      // stacked
      return Column(
        children: [
          buildLabeledField(label1, controller1, keyboardType: keyboard1),
          buildLabeledField(label2, controller2, keyboardType: keyboard2),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: buildLabeledField(label1, controller1,
                keyboardType: keyboard1)),
        const SizedBox(width: 12),
        Expanded(
            child: buildLabeledField(label2, controller2,
                keyboardType: keyboard2)),
      ],
    );
  }

  Widget _buildEmployeeDetailsCard(bool isTwoColumn) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('employee_details'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16))),
                if (!kIsWeb)
                  FittedBox(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on),
                      label: Text('auto_fill'.tr),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent),
                      onPressed: () => _autoFillFromLatestReport(Get.context!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            buildLabeledField(
                'employee_name'.tr, controller.employeeNameController),
            buildLabeledField(
                'employee_phone'.tr, controller.employeePhoneController,
                keyboardType: TextInputType.phone),
            buildLabeledField(
                'employee_code'.tr, controller.employeeCodeController),
            const SizedBox(height: 8),
            _twoFieldRow(
              label1: 'month'.tr,
              controller1: controller.monthController,
              keyboard1: TextInputType.number,
              label2: 'year'.tr,
              controller2: controller.yearController,
              keyboard2: TextInputType.number,
              isTwoColumn: isTwoColumn,
            ),
            buildLabeledField(
                'incharge_name'.tr, controller.inchargeNameController),
            buildLabeledField(
                'incharge_phone'.tr, controller.inchargePhoneController,
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFieldsCard(bool isTwoColumn) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildLabeledField(
                'date'.tr, TextEditingController(text: controller.date),
                enabled: false),
            buildLabeledField('shift'.tr, controller.shiftController),
            buildLabeledField('ot_hours'.tr, controller.otHoursController,
                keyboardType: TextInputType.number),
            buildLabeledField(
                'vehicle_model'.tr, controller.vehicleModelController),
            buildLabeledField('vehicle_reg_no'.tr, controller.regNoController),
            _twoFieldRow(
              label1: 'in_time'.tr,
              controller1: controller.inTimeController,
              label2: 'out_time'.tr,
              controller2: controller.outTimeController,
              isTwoColumn: isTwoColumn,
            ),
            buildLabeledField(
                'working_hours'.tr, controller.workingHoursController,
                keyboardType: TextInputType.number),
            _threeFieldRow(
              isTwoColumn: isTwoColumn,
              label1: 'starting_km'.tr,
              c1: controller.startingKmController,
              label2: 'ending_km'.tr,
              c2: controller.endingKmController,
              label3: 'total_km'.tr,
              c3: controller.totalKmController,
            ),
            _twoFieldRow(
              label1: 'from_place'.tr,
              controller1: controller.fromPlaceController,
              label2: 'to_place'.tr,
              controller2: controller.toPlaceController,
              isTwoColumn: isTwoColumn,
            ),
            buildLabeledField('fuel_avg'.tr, controller.fuelAvgController,
                keyboardType: TextInputType.number),
            buildLabeledField(
                'co_driver_name'.tr, controller.coDriverNameController),
            buildLabeledField(
                'co_driver_phone'.tr, controller.coDriverPhoneController,
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  // row helper for three fields (used for starting/ending/total kms)
  Widget _threeFieldRow({
    required bool isTwoColumn,
    required String label1,
    required TextEditingController c1,
    required String label2,
    required TextEditingController c2,
    required String label3,
    required TextEditingController c3,
  }) {
    // Input formatter for digits-only values (integers). For decimals use different formatter.
    final onlyDigits = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

    // starting & ending - numeric only; total - readOnly & disabled
    final Widget startField = buildLabeledField(label1, c1,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: onlyDigits);
    final Widget endField = buildLabeledField(label2, c2,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: onlyDigits);
    final Widget totalField = buildLabeledField(label3, c3,
        enabled: false,
        readOnly: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: false));

    if (!isTwoColumn) {
      return Column(children: [startField, endField, totalField]);
    }

    return Row(
      children: [
        Expanded(child: startField),
        const SizedBox(width: 8),
        Expanded(child: endField),
        const SizedBox(width: 8),
        Expanded(child: totalField),
      ],
    );
  }


  Widget _buildExtraFieldsCard(bool isTwoColumn) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Vehicle type dropdown using canonical values (so localization doesn't break logic)
            // Vehicle type dropdown (keep option values and labels in English, no translation)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Obx(() {
                // Keep labels in plain English (these are both the displayed text and the value)
                final options = <String>[
                  'Customer Vehicle',
                  'Capitalized Vehicle'
                ];

                final current = controller.selectedVehicleType.value;

                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'capitalized_customer_vehicle'
                        .tr, // you can translate the label itself
                    filled: true,
                    fillColor: Colors.blue[50],
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      // only use current value if it matches one of the option strings
                      value: options.contains(current) ? current : null,
                      hint: Text('select_vehicle_type'.tr),
                      items: options
                          .map((label) => DropdownMenuItem<String>(
                        value: label,
                        child: Text(label, softWrap: true),
                      ))
                          .toList(),
                      onChanged: (val) {
                        // store English text as-is, so autofill remains English
                        controller.selectedVehicleType.value = val;
                        controller.selectedPurposeOfTrial.value = null;
                      },
                    ),
                  ),
                );
              }),
            ),

            // Purpose dropdown (English labels/values only; depends on English vehicle type)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Obx(() {
                final type = controller.selectedVehicleType.value;

                // Purposes are plain English strings (values == labels)
                final Map<String, List<String>> purposeMap = {
                  'Customer Vehicle': [
                    'Post Sale Live Training (Familiarization with product)',
                    'Post Sale FE Trial',
                    'Low Fuel Mileage issue',
                  ],
                  'Capitalized Vehicle': [
                    'Demo',
                    'Pre Sale FE Trial',
                  ],
                };

                final purposes = purposeMap[type] ?? <String>[];

                final currentPurpose = controller.selectedPurposeOfTrial.value;

                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'purpose_of_trial'.tr,
                    filled: true,
                    fillColor: Colors.blue[50],
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: purposes.contains(currentPurpose)
                          ? currentPurpose
                          : null,
                      hint: Text('select_purpose'.tr),
                      items: purposes
                          .map((label) => DropdownMenuItem<String>(
                        value: label,
                        child: Text(label, softWrap: true),
                      ))
                          .toList(),
                      onChanged: (val) =>
                      controller.selectedPurposeOfTrial.value = val,
                    ),
                  ),
                );
              }),
            ),
            // --- Extra fields in responsive layout (two-column where possible) ---
            _twoFieldRow(
              label1: 'chassis_no'.tr,
              controller1: controller.chassisNoController,
              label2: 'gvw'.tr,
              controller2: controller.gvwController,
              keyboard1: TextInputType.text,
              keyboard2: TextInputType.number,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'payload'.tr,
              controller1: controller.payloadController,
              label2: 'present_location'.tr,
              controller2: controller.presentLocationController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'previous_kmpl'.tr,
              controller1: controller.previousKmplController,
              keyboard1: TextInputType.number,
              label2: 'cluster_kmpl'.tr,
              controller2: controller.clusterKmplController,
              keyboard2: TextInputType.number,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'highway_sweet_spot_pct'.tr,
              controller1: controller.highwaySweetSpotPercentController,
              keyboard1: TextInputType.number,
              label2: 'normal_road_sweet_spot_pct'.tr,
              controller2: controller.normalRoadSweetSpotPercentController,
              keyboard2: TextInputType.number,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'hills_road_sweet_spot_pct'.tr,
              controller1: controller.hillsRoadSweetSpotPercentController,
              keyboard1: TextInputType.number,
              label2: 'trial_kmpl'.tr,
              controller2: controller.trialKMPLController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'odo_start_reading'.tr,
              controller1: controller.vehicleOdometerStartingReadingController,
              label2: 'odo_end_reading'.tr,
              controller2: controller.vehicleOdometerEndingReadingController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'trial_kms'.tr,
              controller1: controller.trialKMSController,
              label2: 'trial_allocation'.tr,
              controller2: controller.trialAllocationController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'vecv_reporting_person'.tr,
              controller1: controller.vecvReportingPersonController,
              label2: 'dealer_name'.tr,
              controller2: controller.dealerNameController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'customer_name'.tr,
              controller1: controller.customerNameController,
              label2: 'customer_driver_name'.tr,
              controller2: controller.customerDriverNameController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'customer_driver_no'.tr,
              controller1: controller.customerDriverNoController,
              label2: 'vehicle_no'.tr,
              controller2: controller.vehicleNoController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'capitalized_customer_vehicle'.tr,
              controller1:
              controller.capitalizedVehicleOrCustomerVehicleController,
              label2: 'customer_vehicle'.tr,
              controller2: controller.customerVehicleController,
              isTwoColumn: isTwoColumn,
            ),

            _twoFieldRow(
              label1: 'capitalized_vehicle'.tr,
              controller1: controller.capitalizedVehicleController,
              label2: 'driver_status'.tr,
              controller2: controller.driverStatusController,
              isTwoColumn: isTwoColumn,
            ),

            buildLabeledField(
                'purpose_other'.tr, controller.purposeOfTrialController),
            buildLabeledField('reason'.tr, controller.reasonController),

            _twoFieldRow(
              label1: 'date_of_sale'.tr,
              controller1: controller.dateOfSaleController,
              label2: 'trail_id'.tr,
              controller2: controller.trailIdController,
              isTwoColumn: isTwoColumn,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'incharge_signature'.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        _buildElevatedButton('clear'.tr, Colors.red, () {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('please_provide_signature'.tr)));
      return;
    }

    final td.Uint8List? signature = await _signatureController.toPngBytes();
    if (signature == null) return;

    final now = DateTime.now();
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
      id: null,
      shift: controller.shiftController.text.trim(),
      otHours: _parseInt(controller.otHoursController.text.trim()),
      inTime: _tryParseDateTime(controller.inTimeController.text.trim()),
      outTime: _tryParseDateTime(controller.outTimeController.text.trim()),
      workingHours: _parseInt(controller.workingHoursController.text.trim()),
      monthYear:
      '${controller.monthController.text.trim()}-${controller.yearController.text.trim()}',
      vehicleModel: controller.vehicleModelController.text.trim(),
      regNo: controller.regNoController.text.trim(),
      chassisNo: controller.chassisNoController.text.trim(),
      gvw: _parseDouble(controller.gvwController.text.trim()),
      payload: _parseDouble(controller.payloadController.text.trim()),
      startingKm: _parseInt(controller.startingKmController.text.trim()),
      endingKm: _parseInt(controller.endingKmController.text.trim()),
      totalKm: _parseInt(controller.totalKmController.text.trim()),
      presentLocation: controller.presentLocationController.text.trim(),
      fromPlace: controller.fromPlaceController.text.trim(),
      toPlace: controller.toPlaceController.text.trim(),
      fuelAvg: _parseDouble(controller.fuelAvgController.text.trim()),
      previousKmpl: _parseDouble(controller.previousKmplController.text.trim()),
      clusterKmpl: _parseDouble(controller.clusterKmplController.text.trim()),
      highwaySweetSpotPercent: _parseDouble(
          controller.highwaySweetSpotPercentController.text.trim()),
      normalRoadSweetSpotPercent: _parseDouble(
          controller.normalRoadSweetSpotPercentController.text.trim()),
      hillsRoadSweetSpotPercent: _parseDouble(
          controller.hillsRoadSweetSpotPercentController.text.trim()),
      trialKMPL: controller.trialKMPLController.text.trim(),
      vehicleOdometerStartingReading:
      controller.vehicleOdometerStartingReadingController.text.trim(),
      vehicleOdometerEndingReading:
      controller.vehicleOdometerEndingReadingController.text.trim(),
      trialKMS: controller.trialKMSController.text.trim(),
      trialAllocation: controller.trialAllocationController.text.trim(),
      coDriverName: controller.coDriverNameController.text.trim(),
      coDriverPhoneNo: controller.coDriverPhoneController.text.trim(),
      inchargeSign:
      controller.inchargeSignController.text.trim(), // placeholder
      employeeName: controller.employeeNameController.text.trim(),
      vecvReportingPerson: controller.vecvReportingPersonController.text.trim(),
      employeePhoneNo: controller.employeePhoneController.text.trim(),
      employeeCode: controller.employeeCodeController.text.trim(),
      dicvInchargeName: controller.inchargeNameController.text.trim(),
      dicvInchargePhoneNo: controller.inchargePhoneController.text.trim(),
      dealerName: controller.dealerNameController.text.trim(),
      customerName: controller.customerNameController.text.trim(),
      customerDriverName: controller.customerDriverNameController.text.trim(),
      customerDriverNo: controller.customerDriverNoController.text.trim(),
      capitalizedVehicleOrCustomerVehicle: controller
          .capitalizedVehicleOrCustomerVehicleController.text
          .trim()
          .isNotEmpty
          ? controller.capitalizedVehicleOrCustomerVehicleController.text.trim()
          : (controller.selectedVehicleType.value ?? ''),
      customerVehicle: controller.customerVehicleController.text.trim(),
      capitalizedVehicle: controller.capitalizedVehicleController.text.trim(),
      vehicleNo: controller.vehicleNoController.text.trim(),
      driverStatus: controller.driverStatusController.text.trim(),
      purposeOfTrial: controller.selectedPurposeOfTrial.value ??
          controller.purposeOfTrialController.text.trim(),
      reason: controller.reasonController.text.trim(),
      dateOfSale: controller.dateOfSaleController.text.trim(),
      trailId: controller.trailIdController.text.trim(),
      imageVideoUrls: const [],
      createdAt: now,
      updatedAt: now,
    );

    // debug json
    print('ShiftLog JSON: ${shiftLog.toJson()}');

    Get.to(
          () => DailyReportReviewScreen(
        signature: signature,
        shiftLog: shiftLog,
      ),
    );
  }

  Widget _buildElevatedButton(
      String text, Color? color, VoidCallback onPressed) {
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

  // Helper: label above the field (guarantees label always visible and wraps)
  // Helper: label above the field (guarantees label always visible and wraps)
  Widget buildLabeledField(String label, TextEditingController controller,
      {bool enabled = true,
        bool readOnly = false,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters}) {
    final fillColor = enabled ? (readOnly ? Colors.grey[100] : Colors.blue[50]) : Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueAccent[700])),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: 1,
            style: TextStyle(color: Colors.blueAccent[700], fontSize: 16),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: fillColor,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                BorderSide(color: Colors.blueAccent[100]!, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                BorderSide(color: Colors.blueAccent[700]!, width: 1.8),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // -----------------------
  // Auto-fill implementation
  // -----------------------
  Future<void> _autoFillFromLatestReport(BuildContext context) async {
    final box = GetStorage();
    final storedPhone = (box.read('phone') as String?)?.trim() ?? '';

    if (storedPhone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('driver_phone_not_found'.tr)));
      return;
    }

    final encoded = Uri.encodeComponent(storedPhone);
    final uri = Uri.parse('$apiBaseUrl/dailyReports/latest?phone=$encoded');

    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final Map<String, dynamic>? payload =
        (body is Map && body['payload'] != null)
            ? body['payload'] as Map<String, dynamic>
            : (body is Map ? body as Map<String, dynamic> : null);
        if (payload == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('no_payload_returned'.tr)));
          return;
        }

        _populateFromJson(payload);

        // recalc total after populating (in case server gave start/end but wrong/missing total)
        controller.recalcTotalKm();

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('auto_fill_successful'.tr)));
      } else if (resp.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('no_previous_report_found'.tr)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('server_error'
                .trParams({'code': resp.statusCode.toString()}))));
      }
    } catch (e, st) {
      debugPrint('Auto-fill error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_fetch_latest_report'.tr)));
    }
  }

  // Map payload -> controllers (full mapping)
  void _populateFromJson(Map<String, dynamic> src) {
    controller.shiftController.text = src['shift']?.toString() ?? '';
    controller.otHoursController.text = src['otHours']?.toString() ?? '';
    controller.vehicleModelController.text =
        src['vehicleModel']?.toString() ?? '';
    controller.regNoController.text = src['regNo']?.toString() ?? '';
    controller.inTimeController.text = src['inTime']?.toString() ?? '';
    controller.outTimeController.text = src['outTime']?.toString() ?? '';
    controller.workingHoursController.text =
        src['workingHours']?.toString() ?? '';
    controller.startingKmController.text = src['startingKm']?.toString() ?? '';
    controller.endingKmController.text = src['endingKm']?.toString() ?? '';
    controller.totalKmController.text = src['totalKm']?.toString() ?? '';
    controller.fromPlaceController.text = src['fromPlace']?.toString() ?? '';
    controller.toPlaceController.text = src['toPlace']?.toString() ?? '';
    controller.presentLocationController.text =
        src['presentLocation']?.toString() ?? '';
    controller.fuelAvgController.text = src['fuelAvg']?.toString() ?? '';
    controller.coDriverNameController.text =
        src['coDriverName']?.toString() ?? '';
    controller.coDriverPhoneController.text =
        src['coDriverPhoneNo']?.toString() ?? '';

    // employee fields
    controller.employeeNameController.text =
        src['employeeName']?.toString() ?? '';
    controller.employeePhoneController.text =
        src['employeePhoneNo']?.toString() ?? '';
    controller.employeeCodeController.text =
        src['employeeCode']?.toString() ?? '';

    // monthYear split
    final monthYear = src['monthYear']?.toString() ?? '';
    if (monthYear.contains('-')) {
      final parts = monthYear.split('-');
      controller.monthController.text = parts[0];
      controller.yearController.text = parts.length > 1 ? parts[1] : '';
    } else {
      controller.monthController.text = src['month']?.toString() ?? '';
      controller.yearController.text = src['year']?.toString() ?? '';
    }

    controller.inchargeNameController.text =
        src['dicvInchargeName']?.toString() ?? '';
    controller.inchargePhoneController.text =
        src['dicvInchargePhoneNo']?.toString() ?? '';

    // extra fields
    controller.chassisNoController.text = src['chassisNo']?.toString() ?? '';
    controller.gvwController.text = src['gvw']?.toString() ?? '';
    controller.payloadController.text = src['payload']?.toString() ?? '';
    controller.previousKmplController.text =
        src['previousKmpl']?.toString() ?? '';
    controller.clusterKmplController.text =
        src['clusterKmpl']?.toString() ?? '';
    controller.highwaySweetSpotPercentController.text =
        src['highwaySweetSpotPercent']?.toString() ?? '';
    controller.normalRoadSweetSpotPercentController.text =
        src['normalRoadSweetSpotPercent']?.toString() ?? '';
    controller.hillsRoadSweetSpotPercentController.text =
        src['hillsRoadSweetSpotPercent']?.toString() ?? '';
    controller.trialKMPLController.text = src['trialKMPL']?.toString() ?? '';
    controller.vehicleOdometerStartingReadingController.text =
        src['vehicleOdometerStartingReading']?.toString() ?? '';
    controller.vehicleOdometerEndingReadingController.text =
        src['vehicleOdometerEndingReading']?.toString() ?? '';
    controller.trialKMSController.text = src['trialKMS']?.toString() ?? '';
    controller.trialAllocationController.text =
        src['trialAllocation']?.toString() ?? '';
    controller.vecvReportingPersonController.text =
        src['vecvReportingPerson']?.toString() ?? '';
    controller.dealerNameController.text = src['dealerName']?.toString() ?? '';
    controller.customerNameController.text =
        src['customerName']?.toString() ?? '';
    controller.customerDriverNameController.text =
        src['customerDriverName']?.toString() ?? '';
    controller.customerDriverNoController.text =
        src['customerDriverNo']?.toString() ?? '';
    controller.capitalizedVehicleOrCustomerVehicleController.text =
        src['capitalizedVehicleOrCustomerVehicle']?.toString() ?? '';
    controller.customerVehicleController.text =
        src['customerVehicle']?.toString() ?? '';
    controller.capitalizedVehicleController.text =
        src['capitalizedVehicle']?.toString() ?? '';
    controller.vehicleNoController.text = src['vehicleNo']?.toString() ?? '';
    controller.driverStatusController.text =
        src['driverStatus']?.toString() ?? '';
    controller.reasonController.text = src['reason']?.toString() ?? '';
    controller.dateOfSaleController.text = src['dateOfSale']?.toString() ?? '';
    controller.trailIdController.text = src['trailId']?.toString() ?? '';
    controller.inchargeSignController.text =
        src['inchargeSign']?.toString() ?? '';

    // set reactive dropdowns if values match allowed lists
    final rawType =
        src['capitalizedVehicleOrCustomerVehicle']?.toString() ?? '';
    final normalizedType = _normalizeVehicleType(rawType);
    controller.selectedVehicleType.value = normalizedType;

    final rawPurpose = src['purposeOfTrial']?.toString() ?? '';
    final normalizedPurpose =
    _normalizePurpose(rawPurpose, controller.selectedVehicleType.value);
    controller.selectedPurposeOfTrial.value = normalizedPurpose;
  }

  /// Map server labels or free-text to canonical type: 'customer' | 'capitalized' or null
  String? _normalizeVehicleType(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s.contains('customer')) return 'customer';
    if (s.contains('capital') || s.contains('capitalized'))
      return 'capitalized';
    // sometimes server returns exact canonical words; handle those
    if (s == 'customer' || s == 'capitalized') return s;
    return null; // unknown -> leave null so dropdown shows hint instead of failing
  }

  /// Map server purpose texts to canonical purpose codes depending on vehicle type.
  /// Returns null when not able to map.
  String? _normalizePurpose(String raw, String? vehicleType) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;

    // customer purposes
    final Map<String, String> customerMap = {
      'post sale live training (familiarization with product)':
      'post_sale_live_training',
      'post sale fe trial': 'post_sale_fe_trial',
      'low fuel mileage issue': 'low_fuel_mileage_issue',
    };

    // capitalized purposes
    final Map<String, String> capitalizedMap = {
      'demo': 'demo',
      'pre sale fe trial': 'pre_sale_fe_trial',
    };

    // try exact matches first
    if (customerMap.containsKey(s)) return customerMap[s];
    if (capitalizedMap.containsKey(s)) return capitalizedMap[s];

    // try more permissive checks
    if (s.contains('live training') || s.contains('familiarization'))
      return 'post_sale_live_training';
    if (s.contains('post sale') && s.contains('fe'))
      return 'post_sale_fe_trial';
    if (s.contains('low fuel') || s.contains('mileage'))
      return 'low_fuel_mileage_issue';
    if (s.contains('demo')) return 'demo';
    if (s.contains('pre sale') && s.contains('fe')) return 'pre_sale_fe_trial';

    // Fallback: if server already returned canonical code, accept it
    final known = <String>{
      'post_sale_live_training',
      'post_sale_fe_trial',
      'low_fuel_mileage_issue',
      'demo',
      'pre_sale_fe_trial'
    };
    if (known.contains(s)) return s;

    return null;
  }
}
