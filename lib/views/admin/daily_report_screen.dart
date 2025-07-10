import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shift_log_controller.dart';
import '../../models/shift_log_model.dart';
import '../../utils/file_download_service.dart';
import '../../utils/file_download_service_web.dart';


class DailyReportManagement extends StatelessWidget {
  final ShiftLogController controller = Get.put(ShiftLogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Daily Report Management'),
          ElevatedButton(
            onPressed: () => exportShiftLogsToCsv(controller.shiftLogs),
            child: Text('Export to CSV'),
          )
        ],
      )),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search)),
              onChanged: (query) {
                // TODO: Implement search functionality
              },
            ),
          ),
          Expanded(
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Shift')),
                  DataColumn(label: Text('OT Hours')),
                  DataColumn(label: Text('Vehicle')),
                  DataColumn(label: Text('Reg No')),
                  DataColumn(label: Text('Chassis No')),
                  DataColumn(label: Text('GVW')),
                  DataColumn(label: Text('Payload')),
                  DataColumn(label: Text('Vehicle No')),
                  DataColumn(label: Text('In Time')),
                  DataColumn(label: Text('Out Time')),
                  DataColumn(label: Text('Working Hours')),
                  DataColumn(label: Text('Starting KM')),
                  DataColumn(label: Text('Ending KM')),
                  DataColumn(label: Text('Total KM')),
                  DataColumn(label: Text('From')),
                  DataColumn(label: Text('To')),
                  DataColumn(label: Text('Present Location')),
                  DataColumn(label: Text('Fuel Avg')),
                  DataColumn(label: Text('Prev KMPL')),
                  DataColumn(label: Text('Trial KMPL')),
                  DataColumn(label: Text('Cluster KMPL')),
                  DataColumn(label: Text('Trial KMS')),
                  DataColumn(label: Text('ODO Start')),
                  DataColumn(label: Text('ODO End')),
                  DataColumn(label: Text('Sweet Spot HW')),
                  DataColumn(label: Text('Sweet Spot NR')),
                  DataColumn(label: Text('Sweet Spot Hill')),
                  DataColumn(label: Text('Trial Allocation')),
                  DataColumn(label: Text('Purpose')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Date of Sale')),
                  DataColumn(label: Text('Customer Name')),
                  DataColumn(label: Text('Customer Driver')),
                  DataColumn(label: Text('Customer Driver No')),
                  DataColumn(label: Text('Dealer Name')),
                  DataColumn(label: Text('VECV Reporting')),
                  DataColumn(label: Text('Driver Status')),
                  DataColumn(label: Text('Customer Vehicle')),
                  DataColumn(label: Text('Cap. Vehicle')),
                  DataColumn(label: Text('Cap. Cust/Vehicle')),
                  DataColumn(label: Text('Co-Driver')),
                  DataColumn(label: Text('Co-Driver Phone')),
                  DataColumn(label: Text('Incharge Sign')),
                  DataColumn(label: Text('Employee Name')),
                  DataColumn(label: Text('Employee Phone')),
                  DataColumn(label: Text('Employee Code')),
                  DataColumn(label: Text('Month-Year')),
                  DataColumn(label: Text('DICV Incharge')),
                  DataColumn(label: Text('DICV Phone')),
                  DataColumn(label: Text('Trail ID')),
                  DataColumn(label: Text('Media')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.shiftLogs.map((log) {
                  return DataRow(cells: [
                    DataCell(Text(log.id?.toString() ?? '')),
                    DataCell(Text(log.shift)),
                    DataCell(Text(log.otHours.toString())),
                    DataCell(Text(log.vehicleModel)),
                    DataCell(Text(log.regNo)),
                    DataCell(Text(log.chassisNo)),
                    DataCell(Text(log.gvw.toString())),
                    DataCell(Text(log.payload.toString())),
                    DataCell(Text(log.vehicleNo)),
                    DataCell(Text(log.inTime.toString())),
                    DataCell(Text(log.outTime.toString())),
                    DataCell(Text(log.workingHours.toString())),
                    DataCell(Text(log.startingKm.toString())),
                    DataCell(Text(log.endingKm.toString())),
                    DataCell(Text(log.totalKm.toString())),
                    DataCell(Text(log.fromPlace)),
                    DataCell(Text(log.toPlace)),
                    DataCell(Text(log.presentLocation)),
                    DataCell(Text(log.fuelAvg.toString())),
                    DataCell(Text(log.previousKmpl.toString())),
                    DataCell(Text(log.trialKMPL)),
                    DataCell(Text(log.clusterKmpl.toString())),
                    DataCell(Text(log.trialKMS)),
                    DataCell(Text(log.vehicleOdometerStartingReading)),
                    DataCell(Text(log.vehicleOdometerEndingReading)),
                    DataCell(Text(log.highwaySweetSpotPercent.toString())),
                    DataCell(Text(log.normalRoadSweetSpotPercent.toString())),
                    DataCell(Text(log.hillsRoadSweetSpotPercent.toString())),
                    DataCell(Text(log.trialAllocation)),
                    DataCell(Text(log.purposeOfTrial)),
                    DataCell(Text(log.reason)),
                    DataCell(Text(log.dateOfSale)),
                    DataCell(Text(log.customerName)),
                    DataCell(Text(log.customerDriverName)),
                    DataCell(Text(log.customerDriverNo)),
                    DataCell(Text(log.dealerName)),
                    DataCell(Text(log.vecvReportingPerson)),
                    DataCell(Text(log.driverStatus)),
                    DataCell(Text(log.customerVehicle)),
                    DataCell(Text(log.capitalizedVehicle)),
                    DataCell(Text(log.capitalizedVehicleOrCustomerVehicle)),
                    DataCell(Text(log.coDriverName)),
                    DataCell(Text(log.coDriverPhoneNo)),
                    DataCell(Text(log.inchargeSign)),
                    DataCell(Text(log.employeeName)),
                    DataCell(Text(log.employeePhoneNo)),
                    DataCell(Text(log.employeeCode)),
                    DataCell(Text(log.monthYear)),
                    DataCell(Text(log.dicvInchargeName)),
                    DataCell(Text(log.dicvInchargePhoneNo)),
                    DataCell(Text(log.trailId)),
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
                    DataCell(Row(
                      children: [
                        // IconButton(
                        //   icon: Icon(Icons.visibility),
                        //   onPressed: () {
                        //     // TODO: View details
                        //   },
                        // ),
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
    final selectedVehicleType = RxnString(existingLog?.capitalizedVehicleOrCustomerVehicle);
    final selectedPurposeOfTrial = RxnString(existingLog?.purposeOfTrial);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600, // set custom width
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEdit ? 'Edit Shift Log' : 'Add Shift Log', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Capitalized Vehicle/Customer Vehicle',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent[700]),
                      filled: true,
                      fillColor: Colors.blue[50],
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2),
                      ),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent[700]),
                    value: selectedVehicleType.value,
                    items: [
                      'Customer Vehicle',
                      'Capitalized Vehicle',
                    ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) {
                      selectedVehicleType.value = val;
                      selectedPurposeOfTrial.value = null; // Reset purpose when type changes
                    },
                  )),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Obx(() {
                    final type = selectedVehicleType.value;
                    List<String> purposes = [];
                    if (type == 'Customer Vehicle') {
                      purposes = [
                        'Post Sale Live Training (Familiarization with product)',
                        'Post Sale FE Trial',
                        'Low Fuel Mileage issue',
                      ];
                    } else if (type == 'Capitalized Vehicle') {
                      purposes = [
                        'Demo',
                        'Pre Sale FE Trial',
                      ];
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Purpose of Trial',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent[700]),
                        filled: true,
                        fillColor: Colors.blue[50],
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2),
                        ),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent[700]),
                      value: selectedPurposeOfTrial.value,
                      items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => selectedPurposeOfTrial.value = val,
                    );
                  }),
                ),

                _buildStyledTextField(controller: shiftController, label: 'Shift'),
                _buildStyledTextField(controller: otHoursController, label: 'OT Hours', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: vehicleController, label: 'Vehicle Model'),
                _buildStyledTextField(controller: regNoController, label: 'Registration No'),
                _buildStyledTextField(controller: chassisNoController, label: 'Chassis No'),
                _buildStyledTextField(controller: gvwController, label: 'GVW', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: payloadController, label: 'Payload', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: workingHoursController, label: 'Working Hours', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: startingKmController, label: 'Starting KM', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: endingKmController, label: 'Ending KM', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: totalKmController, label: 'Total KM', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: fromPlaceController, label: 'From Place'),
                _buildStyledTextField(controller: toPlaceController, label: 'To Place'),
                _buildStyledTextField(controller: presentLocationController, label: 'Present Location'),
                _buildStyledTextField(controller: fuelAvgController, label: 'Fuel Avg', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: previousKmplController, label: 'Previous KMPL', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: clusterKmplController, label: 'Cluster KMPL', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: highwaySweetSpotPercentController, label: 'Highway Sweet Spot %', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: normalRoadSweetSpotPercentController, label: 'Normal Road Sweet Spot %', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: hillsRoadSweetSpotPercentController, label: 'Hills Road Sweet Spot %', keyboardType: TextInputType.number),
                _buildStyledTextField(controller: trialKMPLController, label: 'Trial KMPL'),
                _buildStyledTextField(controller: vehicleOdometerStartingReadingController, label: 'Odometer Start Reading'),
                _buildStyledTextField(controller: vehicleOdometerEndingReadingController, label: 'Odometer End Reading'),
                _buildStyledTextField(controller: trialKMSController, label: 'Trial KMS'),
                _buildStyledTextField(controller: trialAllocationController, label: 'Trial Allocation'),
                _buildStyledTextField(controller: coDriverNameController, label: 'Co-Driver Name'),
                _buildStyledTextField(controller: coDriverPhoneNoController, label: 'Co-Driver Phone No'),
                _buildStyledTextField(controller: inchargeSignController, label: 'Incharge Sign'),
                _buildStyledTextField(controller: employeeNameController, label: 'Employee Name'),
                _buildStyledTextField(controller: employeePhoneNoController, label: 'Employee Phone No'),
                _buildStyledTextField(controller: employeeCodeController, label: 'Employee Code'),
                _buildStyledTextField(controller: monthYearController, label: 'Month & Year'),
                _buildStyledTextField(controller: dicvInchargeNameController, label: 'DICV Incharge Name'),
                _buildStyledTextField(controller: dicvInchargePhoneNoController, label: 'DICV Incharge Phone No'),
                _buildStyledTextField(controller: vecvReportingPersonController, label: 'VECV Reporting Person'),
                _buildStyledTextField(controller: dealerNameController, label: 'Dealer Name'),
                _buildStyledTextField(controller: customerNameController, label: 'Customer Name'),
                _buildStyledTextField(controller: customerDriverNameController, label: 'Customer Driver Name'),
                _buildStyledTextField(controller: customerDriverNoController, label: 'Customer Driver No'),
                _buildStyledTextField(controller: capitalizedVehicleOrCustomerVehicleController, label: 'Capitalized Customer Vehicle'),
                _buildStyledTextField(controller: customerVehicleController, label: 'Customer Vehicle'),
                _buildStyledTextField(controller: capitalizedVehicleController, label: 'Capitalized Vehicle'),
                _buildStyledTextField(controller: vehicleNoController, label: 'Vehicle No'),
                _buildStyledTextField(controller: driverStatusController, label: 'Driver Status'),
                _buildStyledTextField(controller: purposeOfTrialController, label: 'Purpose of Trial'),
                _buildStyledTextField(controller: reasonController, label: 'Reason'),
                _buildStyledTextField(controller: dateOfSaleController, label: 'Date of Sale'),
                _buildStyledTextField(controller: trailIdController, label: 'Trail ID'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final shiftLog = ShiftLog(
                          id: existingLog?.id,
                          shift: shiftController.text,
                          otHours: int.tryParse(otHoursController.text) ?? 0,
                          vehicleModel: vehicleController.text,
                          regNo: regNoController.text,
                          chassisNo: chassisNoController.text,
                          gvw: double.tryParse(gvwController.text) ?? 0.0,
                          payload: double.tryParse(payloadController.text) ?? 0.0,
                          inTime: DateTime.now(),
                          outTime: DateTime.now(),
                          workingHours: int.tryParse(workingHoursController.text) ?? 0,
                          startingKm: int.tryParse(startingKmController.text) ?? 0,
                          endingKm: int.tryParse(endingKmController.text) ?? 0,
                          totalKm: int.tryParse(totalKmController.text) ?? 0,
                          presentLocation: presentLocationController.text,
                          fromPlace: fromPlaceController.text,
                          toPlace: toPlaceController.text,
                          fuelAvg: double.tryParse(fuelAvgController.text) ?? 0,
                          previousKmpl: double.tryParse(previousKmplController.text) ?? 0,
                          clusterKmpl: double.tryParse(clusterKmplController.text) ?? 0,
                          highwaySweetSpotPercent: double.tryParse(highwaySweetSpotPercentController.text) ?? 0,
                          normalRoadSweetSpotPercent: double.tryParse(normalRoadSweetSpotPercentController.text) ?? 0,
                          hillsRoadSweetSpotPercent: double.tryParse(hillsRoadSweetSpotPercentController.text) ?? 0,
                          trialKMPL: trialKMPLController.text,
                          vehicleOdometerStartingReading: vehicleOdometerStartingReadingController.text,
                          vehicleOdometerEndingReading: vehicleOdometerEndingReadingController.text,
                          trialKMS: trialKMSController.text,
                          trialAllocation: trialAllocationController.text,
                          coDriverName: coDriverNameController.text,
                          coDriverPhoneNo: coDriverPhoneNoController.text,
                          inchargeSign: inchargeSignController.text,
                          employeeName: employeeNameController.text,
                          employeePhoneNo: employeePhoneNoController.text,
                          employeeCode: employeeCodeController.text,
                          monthYear: monthYearController.text,
                          dicvInchargeName: dicvInchargeNameController.text,
                          dicvInchargePhoneNo: dicvInchargePhoneNoController.text,
                          vecvReportingPerson: vecvReportingPersonController.text,
                          dealerName: dealerNameController.text,
                          customerName: customerNameController.text,
                          customerDriverName: customerDriverNameController.text,
                          customerDriverNo: customerDriverNoController.text,
                          capitalizedVehicleOrCustomerVehicle: selectedVehicleType.value ?? '',
                          customerVehicle: customerVehicleController.text,
                          capitalizedVehicle: capitalizedVehicleController.text,
                          vehicleNo: vehicleNoController.text,
                          driverStatus: driverStatusController.text,
                          purposeOfTrial: selectedPurposeOfTrial.value ?? '',
                          reason: reasonController.text,
                          dateOfSale: dateOfSaleController.text,
                          trailId: trailIdController.text,
                          createdAt: existingLog?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                          imageVideoUrls: [], // Populate appropriately if needed
                        );

                        if (isEdit) {
                          controller.editShiftLog(shiftLog);
                        } else {
                          controller.addShiftLog(shiftLog);
                        }

                        Navigator.of(context).pop();
                      },
                      child: Text(isEdit ? 'Update' : 'Add'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );


  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16, color: Colors.blueAccent[700]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent[700]),
          filled: true,
          fillColor: Colors.blue[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2),
          ),
        ),
      ),
    );
  }

}