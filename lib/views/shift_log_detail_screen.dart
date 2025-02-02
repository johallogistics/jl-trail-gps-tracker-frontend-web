import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shift_log_controller.dart';

class ShiftLogDetailScreen extends StatelessWidget {
  final ShiftLogController controller = Get.put(ShiftLogController());
  final TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Get Shift Log by ID')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Enter Shift Log ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                controller.fetchShiftLogById(idController.text);
              },
              child: Text('Get Shift Log'),
            ),
            SizedBox(height: 20),
            Obx(() {
              if (controller.isLoading.value) {
                return CircularProgressIndicator();
              }
              if (controller.selectedShiftLog.value == null) {
                return Text('No Shift Log found.');
              }

              final log = controller.selectedShiftLog.value!;
              return Card(
                child: ListTile(
                  title: Text('Shift: ${log.payload.shift}'),
                  subtitle: Text('Vehicle: ${log.payload.vehicleModel}, KM: ${log.payload.totalKm}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
