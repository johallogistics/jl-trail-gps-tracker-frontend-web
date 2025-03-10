import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/daily_report_controller.dart';

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
            child: Obx(() => DataTable(
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Shift')),
                DataColumn(label: Text('Vehicle')),
                DataColumn(label: Text('Driver')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.shiftLogs.map((log) {
                return DataRow(cells: [
                  DataCell(Text(log.id.toString())),
                  DataCell(Text(log.shift)),
                  DataCell(Text(log.vehicleModel)),
                  DataCell(Text(log.employeeName)),
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
                        onPressed: () {
                          // TODO: Edit shift log
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.deleteShiftLog(log.id);
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            )),
          )
        ],
      ),
    );
  }
}