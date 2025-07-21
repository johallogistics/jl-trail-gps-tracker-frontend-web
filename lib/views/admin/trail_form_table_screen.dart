import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/new_trail_controller.dart';
import '../../models/trial_form_new_model.dart';
import '../edit_trail_form_screen.dart';
import '../new_trail_form/trial_form_stepper.dart';

class TrialFormTableScreen extends StatelessWidget {
  final controller = Get.put(TrialFormController());

  TrialFormTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trial Forms")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
            columns: const [
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Customer")),
              DataColumn(label: Text("Vehicle No")),
              DataColumn(label: Text("Model")),
              DataColumn(label: Text("Expected FE")),
              DataColumn(label: Text("Actions")),
            ],
            rows: controller.trialForms.map((form) {
              return DataRow(cells: [
                DataCell(Text(form.id?.toString() ?? '')),
                DataCell(Text(form.customerName ?? '')),
                DataCell(Text(form.vehicleNo ?? '')),
                DataCell(Text(form.model ?? '')),
                DataCell(Text(form.customerExpectedFe?.toStringAsFixed(2) ?? '')),

                DataCell(Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                      onPressed: () => showDetailsDialog(context, form),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        // Navigate to edit screen with form data
                        Get.to(() => EditTrialFormScreen(form: form));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Delete",
                          middleText: "Are you sure you want to delete?",
                          textCancel: "Cancel",
                          textConfirm: "Delete",
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            controller.deleteTrialForm(form.id!);
                            Get.back();
                          },
                        );
                      },
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => TrialFormStepper(key: UniqueKey()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showDetailsDialog(BuildContext context, TrialForm form) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Trial Form Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Customer Name: ${form.customerName ?? ''}"),
                Text("Vehicle No: ${form.vehicleNo ?? ''}"),
                const Divider(),

                Text("📸 Photos:"),
                ...(form.photos ?? []).map((p) => Text("- ${p.url}")),

                const Divider(),
                Text("🧑‍🤝‍🧑 Participants:"),
                ...(form.participants ?? []).map((p) =>
                    Text("- ${p.role}: ${p.name} (Sign: ${p.sign})")),

                const Divider(),
                Text("🛣️ Trips:"),
                ...(form.trips ?? []).map((t) => Text(
                    "- ${t.tripNo ?? ''}: ${t.tripStartDate?.toLocal().toString().split(' ')[0]} → ${t.tripEndDate?.toLocal().toString().split(' ')[0]}, ${t.tripKm} KM")),

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
