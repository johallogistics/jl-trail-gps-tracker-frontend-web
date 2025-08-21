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

    Widget tripTile(TripDetail td) => ExpansionTile(
      title: Text('Trip ${td.tripNo == 6 ? 'Overall' : td.tripNo}'),
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Trip Route'),
            onChanged: (v) => td.tripRoute = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'Start Date (ISO)'),
            onChanged: (v) => td.tripStartDate = v,
          )),
          SizedBox(width: 220, child: TextField(
            decoration: const InputDecoration(labelText: 'End Date (ISO)'),
            onChanged: (v) => td.tripEndDate = v,
          )),
          SizedBox(width: 140, child: TextField(
            decoration: const InputDecoration(labelText: 'Start km'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => td.startKm = double.tryParse(v),
          )),
          SizedBox(width: 140, child: TextField(
            decoration: const InputDecoration(labelText: 'End km'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => td.endKm = double.tryParse(v),
          )),
          SizedBox(width: 140, child: TextField(
            decoration: const InputDecoration(labelText: 'Trip km'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => td.tripKm = double.tryParse(v),
          )),
          SizedBox(width: 140, child: TextField(
            decoration: const InputDecoration(labelText: 'Max speed'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => td.maxSpeed = double.tryParse(v),
          )),
          SizedBox(width: 140, child: TextField(
            decoration: const InputDecoration(labelText: 'Weight (GVW)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => td.weightGVW = double.tryParse(v),
          )),
          SizedBox(width: 160, child: TextField(
            decoration: const InputDecoration(labelText: 'Actual Diesel ltrs'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => td.actualDieselLtrs = double.tryParse(v),
          )),
          if (td.tripNo == 6) ...[
            SizedBox(width: 160, child: TextField(
              decoration: const InputDecoration(labelText: 'Total Trip km'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => td.totalTripKm = double.tryParse(v),
            )),
            SizedBox(width: 160, child: TextField(
              decoration: const InputDecoration(labelText: 'Actual FE (kmpl)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => td.actualFE = double.tryParse(v),
            )),
          ],
        ]),
        const SizedBox(height: 8),
      ],
    );

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
          onPressed: c.isSubmitting.value ? null : () => c.submit(createdByRole: submitRole),
          child: Text(c.isSubmitting.value ? 'Submitting...' : 'Submit ($submitRole)'),
        )),
        const SizedBox(height: 60),
      ]),
    );
  }
}