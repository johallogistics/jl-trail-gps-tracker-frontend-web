// lib/widgets/sign_off_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sign_off_controller.dart';
import '../../models/sign_off_models/trip_details.dart';

class SignOffForm extends StatefulWidget {
  final String submitRole; // 'DRIVER' or 'ADMIN'
  const SignOffForm({super.key, required this.submitRole});

  @override
  State<SignOffForm> createState() => _SignOffFormState();
}

class _SignOffFormState extends State<SignOffForm> {
  late final SignOffController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<SignOffController>();

    // Initialize controllers for vehicle details if null
    c.vehicleDetails.vehicleCheckDateController = TextEditingController(text: c.vehicleDetails.vehicleCheckDate);
    c.vehicleDetails.saleDateController = TextEditingController(text: c.vehicleDetails.saleDate);

    // Initialize controllers for each trip
    for (var td in c.tripDetails) {
      td.controllers ??= TripControllers.fromTripDetail(td);
    }
  }

  @override
  void dispose() {
    c.vehicleDetails.vehicleCheckDateController.dispose();
    c.vehicleDetails.saleDateController.dispose();
    for (var td in c.tripDetails) {
      td.controllers?.dispose();
    }
    super.dispose();
  }

  Widget numField(TextEditingController ctl, String label, void Function(String)? onChanged) =>
      SizedBox(
        width: 140,
        child: TextField(
          controller: ctl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
          onChanged: onChanged,
        ),
      );

  Widget textField(TextEditingController ctl, String label, {int maxLines = 1}) =>
      TextField(
        controller: ctl,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      );

  Widget tripTile(TripDetail td) {
    // Use controller from TripDetail so they persist across rebuilds
    td.controllers ??= TripControllers.fromTripDetail(td);

    return ExpansionTile(
      title: Text('Trip ${td.tripNo == 6 ? 'Overall' : td.tripNo}'),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: td.controllers!.tripRoute,
                decoration: const InputDecoration(labelText: 'Trip Route'),
                onChanged: (v) => td.tripRoute = v.isEmpty ? null : v,
              ),
            ),
            DateField(
              controller: td.controllers!.startDate,
              label: 'Start Date',
              onChanged: (v) => td.tripStartDate = v,
            ),
            DateField(
              controller: td.controllers!.endDate,
              label: 'End Date',
              onChanged: (v) => td.tripEndDate = v,
            ),
            numField(td.controllers!.startKm, 'Start km', (v) => td.startKm = v.isEmpty ? null : double.tryParse(v)),
            numField(td.controllers!.endKm, 'End km', (v) => td.endKm = v.isEmpty ? null : double.tryParse(v)),
            numField(td.controllers!.tripKm, 'Trip km', (v) => td.tripKm = v.isEmpty ? null : double.tryParse(v)),
            numField(td.controllers!.maxSpeed, 'Max speed', (v) => td.maxSpeed = v.isEmpty ? null : double.tryParse(v)),
            numField(td.controllers!.weightGVW, 'Weight (GVW)', (v) => td.weightGVW = v.isEmpty ? null : double.tryParse(v)),
            numField(td.controllers!.actualDiesel, 'Actual Diesel ltrs', (v) => td.actualDieselLtrs = v.isEmpty ? null : double.tryParse(v)),
            if (td.tripNo == 6) ...[
              numField(td.controllers!.totalTripKm, 'Total Trip km', (v) => td.totalTripKm = v.isEmpty ? null : double.tryParse(v)),
              numField(td.controllers!.actualFE, 'Actual FE (kmpl)', (v) => td.actualFE = v.isEmpty ? null : double.tryParse(v)),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: c.customerName,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
              ),
              numField(c.customerExpectedFE, 'Customer Expected FE', (v) {}),
              numField(c.beforeTrialsFE, 'Before Trials FE', (v) {}),
              numField(c.afterTrialsFE, 'After Trials FE', (v) {}),
            ],
          ),
          const Divider(height: 32),
          Text('Customer & Vehicle Details', style: Theme.of(context).textTheme.titleMedium),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Trip Duration'),
                  onChanged: (v) => c.vehicleDetails.tripDuration = v,
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Vehicle no'),
                  onChanged: (v) => c.vehicleDetails.vehicleNo = v,
                ),
              ),
              DateField(
                controller: c.vehicleDetails.saleDateController,
                label: 'Sale date',
                onChanged: (v) => c.vehicleDetails.saleDate = v,
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Model'),
                  onChanged: (v) => c.vehicleDetails.model = v,
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Application'),
                  onChanged: (v) => c.vehicleDetails.application = v,
                ),
              ),
              SizedBox(
                width: 480,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Customer Verbatim'),
                  maxLines: 2,
                  onChanged: (v) => c.vehicleDetails.customerVerbatim = v,
                ),
              ),
              SizedBox(
                width: 480,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Trip Route'),
                  onChanged: (v) => c.vehicleDetails.tripRoute = v,
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Road type'),
                  onChanged: (v) => c.vehicleDetails.roadType = v,
                ),
              ),
              DateField(
                controller: c.vehicleDetails.vehicleCheckDateController,
                label: 'Vehicle check date',
                onChanged: (v) => c.vehicleDetails.vehicleCheckDate = v,
              ),
              SizedBox(
                width: 480,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Issues found on vehicle check'),
                  maxLines: 2,
                  onChanged: (v) => c.vehicleDetails.issuesFoundOnVehicleCheck = v,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text('Trials Details', style: Theme.of(context).textTheme.titleMedium),
          Obx(() => Column(children: c.tripDetails.map(tripTile).toList())),
          const Divider(height: 32),
          textField(c.issuesFoundDuringTrial, 'Issues found while trial / driver habits corrected', maxLines: 3),
          const SizedBox(height: 12),
          textField(c.trialRemarks, 'Trial remarks', maxLines: 3),
          const SizedBox(height: 12),
          textField(c.customerRemarks, 'Customer Remarks', maxLines: 3),
          const SizedBox(height: 20),
          Obx(
                () => ElevatedButton(
              onPressed: c.isSubmitting.value
                  ? null
                  : () async {
                if (widget.submitRole == 'DRIVER') {
                  await c.saveProgress();
                  if (c.canDriverSubmitNow()) {
                    final result = await c.submit(createdByRole: 'DRIVER');
                    if (result != null) {
                      Get.snackbar("Submitted", "Trip submitted successfully");
                    }
                  } else {
                    Get.snackbar("Saved", "Progress saved, continue later");
                  }
                } else {
                  final result = await c.submit(createdByRole: 'ADMIN');
                  if (result != null) {
                    Get.offNamed('/signOffList', arguments: {"refresh": true, "updated": result});
                  }
                }
              },
              child: Text(
                c.isSubmitting.value
                    ? 'Submitting...'
                    : c.editingId.value == null
                    ? 'Create (${widget.submitRole})'
                    : widget.submitRole == 'DRIVER'
                    ? 'Save / Submit'
                    : 'Update (${widget.submitRole})',
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

/// Safe date picker field using internal BuildContext
class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String) onChanged;

  const DateField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Builder(
        builder: (ctx) => TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: ctx,
              initialDate: controller.text.isNotEmpty
                  ? DateTime.tryParse(controller.text) ?? DateTime.now()
                  : DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.text = picked.toIso8601String().split('T').first;
              onChanged(controller.text);
            }
          },
        ),
      ),
    );
  }
}
