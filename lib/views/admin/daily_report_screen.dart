import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shift_log_controller.dart';
import '../../models/shift_log_model.dart';

class DailyReportManagement extends StatelessWidget {
  final ShiftLogController controller = Get.put(ShiftLogController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Report Management')),
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
                  DataColumn(label: Text('In Time')),
                  DataColumn(label: Text('Out Time')),
                  DataColumn(label: Text('Working Hours')),
                  DataColumn(label: Text('Starting KM')),
                  DataColumn(label: Text('Ending KM')),
                  DataColumn(label: Text('Total KM')),
                  DataColumn(label: Text('From')),
                  DataColumn(label: Text('To')),
                  DataColumn(label: Text('Fuel Avg')),
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
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.shiftLogs.map((log) {
                  return DataRow(cells: [
                    DataCell(Text(log.id?.toString() ?? '')),
                    DataCell(Text(log.shift)),
                    DataCell(Text(log.otHours.toString())),
                    DataCell(Text(log.vehicleModel)),
                    DataCell(Text(log.regNo)),
                    DataCell(Text(log.inTime.toString())),
                    DataCell(Text(log.outTime.toString())),
                    DataCell(Text(log.workingHours.toString())),
                    DataCell(Text(log.startingKm.toString())),
                    DataCell(Text(log.endingKm.toString())),
                    DataCell(Text(log.totalKm.toString())),
                    DataCell(Text(log.fromPlace)),
                    DataCell(Text(log.toPlace)),
                    DataCell(Text(log.fuelAvg.toString())),
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
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () {
                            // TODO: View details
                          },
                        ),
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
          )
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Shift Log' : 'Add Shift Log'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: shiftController, decoration: InputDecoration(labelText: 'Shift')),
              TextField(controller: otHoursController, decoration: InputDecoration(labelText: 'OT Hours'), keyboardType: TextInputType.number),
              TextField(controller: vehicleController, decoration: InputDecoration(labelText: 'Vehicle Model')),
              TextField(controller: regNoController, decoration: InputDecoration(labelText: 'Registration No')),
              TextField(controller: workingHoursController, decoration: InputDecoration(labelText: 'Working Hours'), keyboardType: TextInputType.number),
              TextField(controller: startingKmController, decoration: InputDecoration(labelText: 'Starting KM'), keyboardType: TextInputType.number),
              TextField(controller: endingKmController, decoration: InputDecoration(labelText: 'Ending KM'), keyboardType: TextInputType.number),
              TextField(controller: totalKmController, decoration: InputDecoration(labelText: 'Total KM'), keyboardType: TextInputType.number),
              TextField(controller: fromPlaceController, decoration: InputDecoration(labelText: 'From Place')),
              TextField(controller: toPlaceController, decoration: InputDecoration(labelText: 'To Place')),
              TextField(controller: fuelAvgController, decoration: InputDecoration(labelText: 'Fuel Avg'), keyboardType: TextInputType.number),
              TextField(controller: coDriverNameController, decoration: InputDecoration(labelText: 'Co-Driver Name')),
              TextField(controller: coDriverPhoneNoController, decoration: InputDecoration(labelText: 'Co-Driver Phone No')),
              TextField(controller: inchargeSignController, decoration: InputDecoration(labelText: 'Incharge Sign')),
              TextField(controller: employeeNameController, decoration: InputDecoration(labelText: 'Employee Name')),
              TextField(controller: employeePhoneNoController, decoration: InputDecoration(labelText: 'Employee Phone No')),
              TextField(controller: employeeCodeController, decoration: InputDecoration(labelText: 'Employee Code')),
              TextField(controller: monthYearController, decoration: InputDecoration(labelText: 'Month & Year')),
              TextField(controller: dicvInchargeNameController, decoration: InputDecoration(labelText: 'DICV Incharge Name')),
              TextField(controller: dicvInchargePhoneNoController, decoration: InputDecoration(labelText: 'DICV Incharge Phone No')),
              TextField(controller: trailIdController, decoration: InputDecoration(labelText: 'Trail ID')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final shiftLog = ShiftLog(
                id: existingLog?.id,
                shift: shiftController.text,
                otHours: int.tryParse(otHoursController.text) ?? 0,
                vehicleModel: vehicleController.text,
                regNo: regNoController.text,
                inTime: DateTime.now(), // In real UI, replace with time picker
                outTime: DateTime.now(), // In real UI, replace with time picker
                workingHours: int.tryParse(workingHoursController.text) ?? 0,
                startingKm: int.tryParse(startingKmController.text) ?? 0,
                endingKm: int.tryParse(endingKmController.text) ?? 0,
                totalKm: int.tryParse(totalKmController.text) ?? 0,
                fromPlace: fromPlaceController.text,
                toPlace: toPlaceController.text,
                fuelAvg: double.tryParse(fuelAvgController.text) ?? 0,
                coDriverName: coDriverNameController.text,
                coDriverPhoneNo: coDriverPhoneNoController.text,
                inchargeSign: inchargeSignController.text,
                employeeName: employeeNameController.text,
                employeePhoneNo: employeePhoneNoController.text,
                employeeCode: employeeCodeController.text,
                monthYear: monthYearController.text,
                dicvInchargeName: dicvInchargeNameController.text,
                dicvInchargePhoneNo: dicvInchargePhoneNoController.text,
                trailId: trailIdController.text,
                createdAt: existingLog?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
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
      ),
    );
  }


}