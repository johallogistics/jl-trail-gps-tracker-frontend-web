import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../controllers/shift_log_controller.dart';
import '../../models/shift_log_model.dart';
import '../../utils/file_download_service.dart';
import '../daily_report_screen.dart';

class DailyReportManagement extends StatefulWidget {
  @override
  State<DailyReportManagement> createState() => _DailyReportManagementState();
}

class _DailyReportManagementState extends State<DailyReportManagement> {
  final ShiftLogController controller = Get.put(ShiftLogController());

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  // TODO: change to your real API base URL
  final String apiBaseUrl = 'https://jl-trail-gps-tracker-backend-production.up.railway.app';
  // Replace with your backend URL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Daily Report Management'),
          ElevatedButton(
            onPressed: () => exportShiftLogsToCsvImpl(controller.shiftLogs),
            child: Text('Export to CSV'),
          )
        ],
      )),
      body: Column(
        children: [
          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: TextField(
          //     decoration: InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search)),
          //     onChanged: (query) {
          //       // TODO: Implement search functionality
          //     },
          //   ),
          // ),
          Expanded(
            child: Obx(() => Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('S.NO')),
                    DataColumn(label: Text('REGION')),
                    DataColumn(label: Text('EMP CODE')),
                    DataColumn(label: Text('DRIVER NAME')),
                    DataColumn(label: Text('Allocation')),
                    DataColumn(label: Text('Contact No.')),
                    DataColumn(label: Text('Designation')),
                    DataColumn(label: Text('Native Place')),
                    DataColumn(label: Text('Available at')),
                    DataColumn(label: Text('Driver Status')),
                    DataColumn(label: Text('Capitalized Vehicle/Customer Vehicle')),
                    DataColumn(label: Text('Purpose of Trial')),
                    DataColumn(label: Text('Reason, If Others')),
                    DataColumn(label: Text('Date Of Sale')),
                    DataColumn(label: Text('VECV reporting Person')),
                    DataColumn(label: Text('Dealer Name')),
                    DataColumn(label: Text('Customer Name')),
                    DataColumn(label: Text('Customer Driver Name')),
                    DataColumn(label: Text('Customer Driver No')),
                    DataColumn(label: Text('Present location')),
                    DataColumn(label: Text('Vehicle No')),
                    DataColumn(label: Text('Chassis No')),
                    DataColumn(label: Text('Vehicle Model')),
                    DataColumn(label: Text('GVW')),
                    DataColumn(label: Text('Payload')),
                    DataColumn(label: Text('Previous KMPL')),
                    DataColumn(label: Text('Trial KMPL')),
                    DataColumn(label: Text('cluster KMPL')),
                    DataColumn(label: Text('Vehicle Odometer - Start')),
                    DataColumn(label: Text('Vehicle Odometer - End')),
                    DataColumn(label: Text('Trial KMS')),
                    DataColumn(label: Text('HighWay Sweet Spot %')),
                    DataColumn(label: Text('Normal Road Sweet Spot %')),
                    DataColumn(label: Text('Hills Road Sweet Spot %')),
                    DataColumn(label: Text('Trial Allocation')),
                    DataColumn(label: Text('Media')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: controller.shiftLogs.map((log) {
                    return DataRow(cells: [
                      // NOTE: mapping assumptions below — change as required.
                      //  S.NO
                      DataCell(Text(log.id?.toString() ?? '')),

                      // REGION
                      DataCell(Text(log.region ?? '-')),

                      // EMP CODE  -> ShiftLog.employeeCode
                      DataCell(Text(log.employeeCode)),

                      // DRIVER NAME -> ShiftLog.employeeName
                      DataCell(Text(log.employeeName)),

                      // Allocation -> ShiftLog.trialAllocation
                      DataCell(Text(log.allocation.toString())),

                      // Contact No. -> employeePhoneNo
                      DataCell(Text(log.employeePhoneNo)),

                      // Designation -> ASSUMED mapping: capitalizedVehicle (no explicit designation field available)
                      // If you have a separate designation field, replace this with that.
                      DataCell(Text(log.capitalizedVehicle)),

                      // Native Place -> presentLocation
                      DataCell(Text(log.presentLocation)),

                      // Available at -> fromPlace (you can change to toPlace if preferred)
                      DataCell(Text(log.fromPlace)),

                      // Driver Status -> driverStatus
                      DataCell(Text(log.driverStatus)),

                      // Capitalized Vehicle/Customer Vehicle -> capitalizedVehicleOrCustomerVehicle
                      DataCell(Text(log.capitalizedVehicleOrCustomerVehicle)),

                      // Purpose of Trial -> purposeOfTrial
                      DataCell(Text(log.purposeOfTrial)),

                      // Reason, If Others -> reason
                      DataCell(Text(log.reason)),

                      // Date Of Sale -> dateOfSale
                      DataCell(Text(log.dateOfSale)),

                      // VECV reporting Person -> vecvReportingPerson
                      DataCell(Text(log.vecvReportingPerson)),

                      // Dealer Name -> dealerName
                      DataCell(Text(log.dealerName)),

                      // Customer Name -> customerName
                      DataCell(Text(log.customerName)),

                      // Customer Driver Name -> customerDriverName
                      DataCell(Text(log.customerDriverName)),

                      // Customer Driver No -> customerDriverNo
                      DataCell(Text(log.customerDriverNo)),

                      // Present location -> presentLocation (duplicate kept because requested)
                      DataCell(Text(log.presentLocation)),

                      // Vehicle No -> vehicleNo
                      DataCell(Text(log.vehicleNo)),

                      // Chassis No -> chassisNo
                      DataCell(Text(log.chassisNo)),

                      // Vehicle Model -> vehicleModel
                      DataCell(Text(log.vehicleModel)),

                      // GVW -> gvw
                      DataCell(Text(log.gvw.toString())),

                      // Payload -> payload
                      DataCell(Text(log.payload.toString())),

                      // Previous KMPL -> previousKmpl
                      DataCell(Text(log.previousKmpl.toString())),

                      // Trial KMPL -> trialKMPL
                      DataCell(Text(log.trialKMPL)),

                      // cluster KMPL -> clusterKmpl
                      DataCell(Text(log.clusterKmpl.toString())),

                      // Vehicle Odometer - Start -> vehicleOdometerStartingReading
                      DataCell(Text(log.vehicleOdometerStartingReading)),

                      // Vehicle Odometer - End -> vehicleOdometerEndingReading
                      DataCell(Text(log.vehicleOdometerEndingReading)),

                      // Trial KMS -> trialKMS
                      DataCell(Text(log.trialKMS)),

                      // HighWay Sweet Spot % -> highwaySweetSpotPercent
                      DataCell(Text(log.highwaySweetSpotPercent.toString())),

                      // Normal Road Sweet Spot % -> normalRoadSweetSpotPercent
                      DataCell(Text(log.normalRoadSweetSpotPercent.toString())),

                      // Hills Road Sweet Spot % -> hillsRoadSweetSpotPercent
                      DataCell(Text(log.hillsRoadSweetSpotPercent.toString())),

                      // Trial Allocation (again) -> trialAllocation
                      DataCell(Text(log.trialAllocation)),

                      // Media (download icon)
                      DataCell(
                        log.imageVideoUrls.isEmpty
                            ? Icon(Icons.insert_drive_file, color: Colors.grey)
                            : IconButton(
                          icon: Icon(Icons.download, color: Colors.blue),
                          onPressed: () async {
                            for (var url in log.imageVideoUrls) {
                              await downloadFileFromUrl(url);
                            }
                          },
                        ),
                      ),

                      // Actions (edit/delete)
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showAddShiftLogDialog(context, isEdit: true, existingLog: log),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, log.id!),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddShiftLogDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Confirmation"),
        content: Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteShiftLog(id);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAddShiftLogDialog(BuildContext context, {bool isEdit = false, ShiftLog? existingLog}) {
    final shiftController = TextEditingController(text: existingLog?.shift ?? '');
    final otHoursController = TextEditingController(text: existingLog?.otHours.toString() ?? '0');
    final vehicleController = TextEditingController(text: existingLog?.vehicleModel ?? '');
    final regNoController = TextEditingController(text: existingLog?.regNo ?? '');
    final workingHoursController = TextEditingController(text: existingLog?.workingHours.toString() ?? '0');
    final startingKmController = TextEditingController(text: existingLog?.startingKm.toString() ?? '0');
    final endingKmController = TextEditingController(text: existingLog?.endingKm.toString() ?? '0');
    final totalKmController = TextEditingController(text: existingLog?.totalKm.toString() ?? '0');
    final fromPlaceController = TextEditingController(text: existingLog?.fromPlace ?? '');
    final toPlaceController = TextEditingController(text: existingLog?.toPlace ?? '');
    final fuelAvgController = TextEditingController(text: existingLog?.fuelAvg.toString() ?? '0');
    final coDriverNameController = TextEditingController(text: existingLog?.coDriverName ?? '');
    final coDriverPhoneNoController = TextEditingController(text: existingLog?.coDriverPhoneNo ?? '');
    final inchargeSignController = TextEditingController(text: existingLog?.inchargeSign ?? '');
    final employeeNameController = TextEditingController(text: existingLog?.employeeName ?? '');
    final employeePhoneNoController = TextEditingController(text: existingLog?.employeePhoneNo ?? '');
    final employeeCodeController = TextEditingController(text: existingLog?.employeeCode ?? '');
    final monthYearController = TextEditingController(text: existingLog?.monthYear ?? '');
    final dicvInchargeNameController = TextEditingController(text: existingLog?.dicvInchargeName ?? '');
    final dicvInchargePhoneNoController = TextEditingController(text: existingLog?.dicvInchargePhoneNo ?? '');
    final trailIdController = TextEditingController(text: existingLog?.trailId ?? '');
    final chassisNoController = TextEditingController(text: existingLog?.chassisNo ?? '');
    final gvwController = TextEditingController(text: existingLog?.gvw.toString() ?? '0');
    final payloadController = TextEditingController(text: existingLog?.payload.toString() ?? '0');
    final presentLocationController = TextEditingController(text: existingLog?.presentLocation ?? '');
    final previousKmplController = TextEditingController(text: existingLog?.previousKmpl.toString() ?? '0');
    final clusterKmplController = TextEditingController(text: existingLog?.clusterKmpl.toString() ?? '0');
    final highwaySweetSpotPercentController = TextEditingController(text: existingLog?.highwaySweetSpotPercent.toString() ?? '0');
    final normalRoadSweetSpotPercentController = TextEditingController(text: existingLog?.normalRoadSweetSpotPercent.toString() ?? '0');
    final hillsRoadSweetSpotPercentController = TextEditingController(text: existingLog?.hillsRoadSweetSpotPercent.toString() ?? '0');
    final trialKMPLController = TextEditingController(text: existingLog?.trialKMPL ?? '');
    final vehicleOdometerStartingReadingController = TextEditingController(text: existingLog?.vehicleOdometerStartingReading ?? '');
    final vehicleOdometerEndingReadingController = TextEditingController(text: existingLog?.vehicleOdometerEndingReading ?? '');
    final trialKMSController = TextEditingController(text: existingLog?.trialKMS ?? '');
    final trialAllocationController = TextEditingController(text: existingLog?.trialAllocation ?? '');
    final vecvReportingPersonController = TextEditingController(text: existingLog?.vecvReportingPerson ?? '');
    final dealerNameController = TextEditingController(text: existingLog?.dealerName ?? '');
    final customerNameController = TextEditingController(text: existingLog?.customerName ?? '');
    final customerDriverNameController = TextEditingController(text: existingLog?.customerDriverName ?? '');
    final customerDriverNoController = TextEditingController(text: existingLog?.customerDriverNo ?? '');
    final capitalizedVehicleOrCustomerVehicleController = TextEditingController(text: existingLog?.capitalizedVehicleOrCustomerVehicle ?? '');
    final customerVehicleController = TextEditingController(text: existingLog?.customerVehicle ?? '');
    final capitalizedVehicleController = TextEditingController(text: existingLog?.capitalizedVehicle ?? '');
    final vehicleNoController = TextEditingController(text: existingLog?.vehicleNo ?? '');
    final driverStatusController = TextEditingController(text: existingLog?.driverStatus ?? '');
    final purposeOfTrialController = TextEditingController(text: existingLog?.purposeOfTrial ?? '');
    final reasonController = TextEditingController(text: existingLog?.reason ?? '');
    final dateOfSaleController = TextEditingController(text: existingLog?.dateOfSale ?? '');
    final regionController = TextEditingController(text: existingLog?.region ?? ''); // NEW
    final selectedVehicleType = RxnString(existingLog?.capitalizedVehicleOrCustomerVehicle);
    final selectedPurposeOfTrial = RxnString(existingLog?.purposeOfTrial);

    // Auto Fill helper - visible only on non-web
    Future<void> _autoFillFromLatestReport() async {
      final box = GetStorage();
      final storedPhone = (box.read('phone') as String?)?.trim() ?? '';

      if (storedPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Driver phone not found in storage.'))
        );
        return;
      }

      // Decide whether you want to enforce leading + on client side.
      // If storedPhone already contains +, this will encode it as %2B.
      final encodedPhone = Uri.encodeComponent(storedPhone);

      print("STORED:::::::::::::::: $storedPhone");

      final uri = Uri.parse('https://jl-trail-gps-tracker-backend-production.up.railway.app/dailyReports/latest?phone=$encodedPhone');

      try {
        final resp = await http.get(uri);
        if (resp.statusCode == 200) {
          final body = json.decode(resp.body);
          final Map<String, dynamic>? payload = (body is Map && body['payload'] != null) ? body['payload'] as Map<String, dynamic> : (body is Map ? body as Map<String, dynamic> : null);

          if (payload == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No payload returned')));
            return;
          }

          // call the helper you already have (make sure it's in scope)
          _populateFormFromJson(
            payload,
            shiftController: shiftController,
            otHoursController: otHoursController,
            vehicleController: vehicleController,
            regNoController: regNoController,
            workingHoursController: workingHoursController,
            startingKmController: startingKmController,
            endingKmController: endingKmController,
            totalKmController: totalKmController,
            fromPlaceController: fromPlaceController,
            toPlaceController: toPlaceController,
            fuelAvgController: fuelAvgController,
            coDriverNameController: coDriverNameController,
            coDriverPhoneNoController: coDriverPhoneNoController,
            inchargeSignController: inchargeSignController,
            employeeNameController: employeeNameController,
            employeePhoneNoController: employeePhoneNoController,
            employeeCodeController: employeeCodeController,
            monthYearController: monthYearController,
            dicvInchargeNameController: dicvInchargeNameController,
            dicvInchargePhoneNoController: dicvInchargePhoneNoController,
            trailIdController: trailIdController,
            chassisNoController: chassisNoController,
            gvwController: gvwController,
            payloadController: payloadController,
            presentLocationController: presentLocationController,
            previousKmplController: previousKmplController,
            clusterKmplController: clusterKmplController,
            highwaySweetSpotPercentController: highwaySweetSpotPercentController,
            normalRoadSweetSpotPercentController: normalRoadSweetSpotPercentController,
            hillsRoadSweetSpotPercentController: hillsRoadSweetSpotPercentController,
            trialKMPLController: trialKMPLController,
            vehicleOdometerStartingReadingController: vehicleOdometerStartingReadingController,
            vehicleOdometerEndingReadingController: vehicleOdometerEndingReadingController,
            trialKMSController: trialKMSController,
            trialAllocationController: trialAllocationController,
            vecvReportingPersonController: vecvReportingPersonController,
            dealerNameController: dealerNameController,
            customerNameController: customerNameController,
            customerDriverNameController: customerDriverNameController,
            customerDriverNoController: customerDriverNoController,
            capitalizedVehicleOrCustomerVehicleController: capitalizedVehicleOrCustomerVehicleController,
            customerVehicleController: customerVehicleController,
            capitalizedVehicleController: capitalizedVehicleController,
            vehicleNoController: vehicleNoController,
            driverStatusController: driverStatusController,
            purposeOfTrialController: purposeOfTrialController,
            reasonController: reasonController,
            dateOfSaleController: dateOfSaleController,
            regionController: regionController, // NEW
            selectedVehicleType: selectedVehicleType,
            selectedPurposeOfTrial: selectedPurposeOfTrial,
          );

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-fill successful')));
        } else if (resp.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No previous report found for this driver')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${resp.statusCode}')));
        }
      } catch (e) {
        debugPrint('Auto-fill error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch latest report')));
      }
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 900, maxHeight: 780),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: DailyReportScreen(
              isEdit: isEdit,
              existingLog: existingLog,
            ), // <-- pass existingLog & isEdit flag
          ),
        ),
      ),
    );

  }

  // Helper to populate controllers from JSON payload (best-effort mapping)
  void _populateFormFromJson(
      Map<String, dynamic> src, {
        required TextEditingController shiftController,
        required TextEditingController otHoursController,
        required TextEditingController vehicleController,
        required TextEditingController regNoController,
        required TextEditingController workingHoursController,
        required TextEditingController startingKmController,
        required TextEditingController endingKmController,
        required TextEditingController totalKmController,
        required TextEditingController fromPlaceController,
        required TextEditingController toPlaceController,
        required TextEditingController fuelAvgController,
        required TextEditingController coDriverNameController,
        required TextEditingController coDriverPhoneNoController,
        required TextEditingController inchargeSignController,
        required TextEditingController employeeNameController,
        required TextEditingController employeePhoneNoController,
        required TextEditingController employeeCodeController,
        required TextEditingController monthYearController,
        required TextEditingController dicvInchargeNameController,
        required TextEditingController dicvInchargePhoneNoController,
        required TextEditingController trailIdController,
        required TextEditingController chassisNoController,
        required TextEditingController gvwController,
        required TextEditingController payloadController,
        required TextEditingController presentLocationController,
        required TextEditingController previousKmplController,
        required TextEditingController clusterKmplController,
        required TextEditingController highwaySweetSpotPercentController,
        required TextEditingController normalRoadSweetSpotPercentController,
        required TextEditingController hillsRoadSweetSpotPercentController,
        required TextEditingController trialKMPLController,
        required TextEditingController vehicleOdometerStartingReadingController,
        required TextEditingController vehicleOdometerEndingReadingController,
        required TextEditingController trialKMSController,
        required TextEditingController trialAllocationController,
        required TextEditingController vecvReportingPersonController,
        required TextEditingController dealerNameController,
        required TextEditingController customerNameController,
        required TextEditingController customerDriverNameController,
        required TextEditingController customerDriverNoController,
        required TextEditingController capitalizedVehicleOrCustomerVehicleController,
        required TextEditingController customerVehicleController,
        required TextEditingController capitalizedVehicleController,
        required TextEditingController vehicleNoController,
        required TextEditingController driverStatusController,
        required TextEditingController purposeOfTrialController,
        required TextEditingController reasonController,
        required TextEditingController dateOfSaleController,
        required TextEditingController regionController, // NEW
        required RxnString selectedVehicleType,
        required RxnString selectedPurposeOfTrial,
      }) {
    // Simple safe reads with fallback to empty strings
    shiftController.text = src['shift']?.toString() ?? '';
    otHoursController.text = src['otHours']?.toString() ?? '0';
    vehicleController.text = src['vehicleModel']?.toString() ?? '';
    regNoController.text = src['regNo']?.toString() ?? '';
    workingHoursController.text = src['workingHours']?.toString() ?? '0';
    startingKmController.text = src['startingKm']?.toString() ?? '0';
    endingKmController.text = src['endingKm']?.toString() ?? '0';
    totalKmController.text = src['totalKm']?.toString() ?? '0';
    fromPlaceController.text = src['fromPlace']?.toString() ?? '';
    toPlaceController.text = src['toPlace']?.toString() ?? '';
    fuelAvgController.text = src['fuelAvg']?.toString() ?? '0';
    coDriverNameController.text = src['coDriverName']?.toString() ?? '';
    coDriverPhoneNoController.text = src['coDriverPhoneNo']?.toString() ?? '';
    inchargeSignController.text = src['inchargeSign']?.toString() ?? '';
    employeeNameController.text = src['employeeName']?.toString() ?? '';
    employeePhoneNoController.text = src['employeePhoneNo']?.toString() ?? '';
    employeeCodeController.text = src['employeeCode']?.toString() ?? '';
    monthYearController.text = src['monthYear']?.toString() ?? '';
    dicvInchargeNameController.text = src['dicvInchargeName']?.toString() ?? '';
    dicvInchargePhoneNoController.text = src['dicvInchargePhoneNo']?.toString() ?? '';
    trailIdController.text = src['trailId']?.toString() ?? '';
    chassisNoController.text = src['chassisNo']?.toString() ?? '';
    gvwController.text = src['gvw']?.toString() ?? '0';
    payloadController.text = src['payload']?.toString() ?? '0';
    presentLocationController.text = src['presentLocation']?.toString() ?? '';
    previousKmplController.text = src['previousKmpl']?.toString() ?? '0';
    clusterKmplController.text = src['clusterKmpl']?.toString() ?? '0';
    highwaySweetSpotPercentController.text = src['highwaySweetSpotPercent']?.toString() ?? '0';
    normalRoadSweetSpotPercentController.text = src['normalRoadSweetSpotPercent']?.toString() ?? '0';
    hillsRoadSweetSpotPercentController.text = src['hillsRoadSweetSpotPercent']?.toString() ?? '0';
    trialKMPLController.text = src['trialKMPL']?.toString() ?? '';
    vehicleOdometerStartingReadingController.text = src['vehicleOdometerStartingReading']?.toString() ?? '';
    vehicleOdometerEndingReadingController.text = src['vehicleOdometerEndingReading']?.toString() ?? '';
    trialKMSController.text = src['trialKMS']?.toString() ?? '';

    // trialAllocation: keep existing behavior; ensure fallback compatibility
    trialAllocationController.text = src['trialAllocation']?.toString() ?? '';

    vecvReportingPersonController.text = src['vecvReportingPerson']?.toString() ?? '';
    dealerNameController.text = src['dealerName']?.toString() ?? '';
    customerNameController.text = src['customerName']?.toString() ?? '';
    customerDriverNameController.text = src['customerDriverName']?.toString() ?? '';
    customerDriverNoController.text = src['customerDriverNo']?.toString() ?? '';
    capitalizedVehicleOrCustomerVehicleController.text = src['capitalizedVehicleOrCustomerVehicle']?.toString() ?? '';
    customerVehicleController.text = src['customerVehicle']?.toString() ?? '';
    capitalizedVehicleController.text = src['capitalizedVehicle']?.toString() ?? '';
    vehicleNoController.text = src['vehicleNo']?.toString() ?? '';
    driverStatusController.text = src['driverStatus']?.toString() ?? '';
    purposeOfTrialController.text = src['purposeOfTrial']?.toString() ?? '';
    reasonController.text = src['reason']?.toString() ?? '';
    dateOfSaleController.text = src['dateOfSale']?.toString() ?? '';

    // NEW: populate region (if server has it)
    regionController.text = src['region']?.toString() ?? '';

    // Set reactive dropdown values where applicable
    final typeVal = src['capitalizedVehicleOrCustomerVehicle']?.toString();
    if (typeVal == 'Customer Vehicle' || typeVal == 'Capitalized Vehicle') {
      selectedVehicleType.value = typeVal;
    } else {
      selectedVehicleType.value = null;
    }

    final purposeVal = src['purposeOfTrial']?.toString();
    // check it's in allowed lists
    final allowedCustomerPurposes = [
      'Post Sale Live Training (Familiarization with product)',
      'Post Sale FE Trial',
      'Low Fuel Mileage issue'
    ];
    final allowedCapitalizedPurposes = ['Demo', 'Pre Sale FE Trial'];
    if (allowedCustomerPurposes.contains(purposeVal) || allowedCapitalizedPurposes.contains(purposeVal)) {
      selectedPurposeOfTrial.value = purposeVal;
    } else {
      selectedPurposeOfTrial.value = null;
    }
  }
}
