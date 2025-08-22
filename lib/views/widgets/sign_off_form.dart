// lib/widgets/sign_off_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sign_off_controller.dart';
import '../../models/sign_off_models/trip_details.dart';

class SignOffForm extends StatelessWidget {
  final String submitRole; // 'DRIVER' or 'ADMIN'
  const SignOffForm({super.key, required this.submitRole});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SignOffController>();

    Widget numField(TextEditingController ctl, String label) => SizedBox(
      width: 140,
      child: TextField(
        controller: ctl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );

    Widget textField(TextEditingController ctl, String label, {int maxLines = 1}) => TextField(
      controller: ctl,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );

    Widget tripTile(TripDetail td) {
      final tripRouteCtl = TextEditingController(text: td.tripRoute ?? '');
      final startDateCtl = TextEditingController(text: td.tripStartDate ?? '');
      final endDateCtl = TextEditingController(text: td.tripEndDate ?? '');
      final startKmCtl = TextEditingController(text: td.startKm?.toString() ?? '');
      final endKmCtl = TextEditingController(text: td.endKm?.toString() ?? '');
      final tripKmCtl = TextEditingController(text: td.tripKm?.toString() ?? '');
      final maxSpeedCtl = TextEditingController(text: td.maxSpeed?.toString() ?? '');
      final weightCtl = TextEditingController(text: td.weightGVW?.toString() ?? '');
      final dieselCtl = TextEditingController(text: td.actualDieselLtrs?.toString() ?? '');
      final totalKmCtl = TextEditingController(text: td.totalTripKm?.toString() ?? '');
      final feCtl = TextEditingController(text: td.actualFE?.toString() ?? '');

      // helper builder
      Widget numField(TextEditingController ctl, String label, void Function(String) onChanged) =>
          SizedBox(
            width: 140,
            child: TextField(
              controller: ctl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: label),
              onChanged: onChanged,
            ),
          );

      return ExpansionTile(
        title: Text('Trip ${td.tripNo == 6 ? 'Overall' : td.tripNo}'),
        children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: tripRouteCtl,
                decoration: const InputDecoration(labelText: 'Trip Route'),
                onChanged: (v) => td.tripRoute = v.isEmpty ? null : v,
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: startDateCtl,
                decoration: const InputDecoration(labelText: 'Start Date (ISO)'),
                onChanged: (v) => td.tripStartDate = v.isEmpty ? null : v,
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: endDateCtl,
                decoration: const InputDecoration(labelText: 'End Date (ISO)'),
                onChanged: (v) => td.tripEndDate = v.isEmpty ? null : v,
              ),
            ),
            numField(startKmCtl, 'Start km',
                    (v) => td.startKm = v.isEmpty ? null : double.tryParse(v)),
            numField(endKmCtl, 'End km',
                    (v) => td.endKm = v.isEmpty ? null : double.tryParse(v)),
            numField(tripKmCtl, 'Trip km',
                    (v) => td.tripKm = v.isEmpty ? null : double.tryParse(v)),
            numField(maxSpeedCtl, 'Max speed',
                    (v) => td.maxSpeed = v.isEmpty ? null : double.tryParse(v)),
            numField(weightCtl, 'Weight (GVW)',
                    (v) => td.weightGVW = v.isEmpty ? null : double.tryParse(v)),
            numField(dieselCtl, 'Actual Diesel ltrs',
                    (v) => td.actualDieselLtrs = v.isEmpty ? null : double.tryParse(v)),
            if (td.tripNo == 6) ...[
              numField(totalKmCtl, 'Total Trip km',
                      (v) => td.totalTripKm = v.isEmpty ? null : double.tryParse(v)),
              numField(feCtl, 'Actual FE (kmpl)',
                      (v) => td.actualFE = v.isEmpty ? null : double.tryParse(v)),
            ],
          ]),
          const SizedBox(height: 8),
        ],
      );
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 280, child: TextField(
            controller: c.customerName,
            decoration: const InputDecoration(labelText: 'Customer Name'),
          )),
          numField(c.customerExpectedFE, 'Customer Expected FE'),
          numField(c.beforeTrialsFE, 'Before Trials FE'),
          numField(c.afterTrialsFE, 'After Trials FE'),
        ]),
        const Divider(height: 32),
        Text('Customer & Vehicle Details', style: Theme.of(context).textTheme.titleMedium),
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Trip Duration'),
            onChanged: (v) => c.vehicleDetails.tripDuration = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Vehicle no'),
            onChanged: (v) => c.vehicleDetails.vehicleNo = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Sale date (ISO)'),
            onChanged: (v) => c.vehicleDetails.saleDate = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Model'),
            onChanged: (v) => c.vehicleDetails.model = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Application'),
            onChanged: (v) => c.vehicleDetails.application = v,
          )),
          SizedBox(width: 480, child: TextField(
            decoration: const InputDecoration(labelText: 'Customer Verbatim'),
            maxLines: 2,
            onChanged: (v) => c.vehicleDetails.customerVerbatim = v,
          )),
          SizedBox(width: 480, child: TextField(
            decoration: const InputDecoration(labelText: 'Trip Route'),
            onChanged: (v) => c.vehicleDetails.tripRoute = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Road type'),
            onChanged: (v) => c.vehicleDetails.roadType = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Vehicle check date (ISO)'),
            onChanged: (v) => c.vehicleDetails.vehicleCheckDate = v,
          )),
          SizedBox(width: 480, child: TextField(
            decoration: const InputDecoration(labelText: 'Issues found on vehicle check'),
            maxLines: 2,
            onChanged: (v) => c.vehicleDetails.issuesFoundOnVehicleCheck = v,
          )),
        ]),
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
        Obx(() => ElevatedButton(
          onPressed: c.isSubmitting.value
              ? null
              : () async {
            if (submitRole == 'DRIVER') {
              // DRIVER → if trip not complete yet, just save progress
              if (!c.tripDetails.every((t) => t.tripEndDate != null)) {
                await c.saveProgress();
                Get.snackbar("Saved", "Progress saved, continue later");
              } else {
                // trip complete → submit
                final result = await c.submit(createdByRole: 'DRIVER');
                if (result != null) {
                  Get.snackbar("Submitted", "Trip submitted successfully");
                }
              }
            } else {
              // ADMIN flow
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
                ? 'Create ($submitRole)'
                : submitRole == 'DRIVER'
                ? 'Save / Submit'
                : 'Update ($submitRole)',
          ),
        )),
        const SizedBox(height: 60),
      ]),
    );
  }
}