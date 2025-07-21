import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/new_trail_controller.dart';

class TripForm extends StatelessWidget {
  final int tripIndex;
  final controller = Get.find<TrialFormController>();

  TripForm({required this.tripIndex, super.key}) {
    controller.ensureTripExists(tripIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final trips = controller.form.value.trips ?? [];
      final trip = trips[tripIndex];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          runSpacing: 16,
          spacing: 16,
          children: [
            _buildTextField("Trip No", trip.tripNo ?? '', (v) {
              trip.tripNo = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildTextField("Trip Route", trip.tripRoute ?? '', (v) {
              trip.tripRoute = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildDatePicker(context, "Start Date", trip.tripStartDate, (d) {
              trip.tripStartDate = d;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildDatePicker(context, "End Date", trip.tripEndDate, (d) {
              trip.tripEndDate = d;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Start KM", trip.startKm, (v) {
              trip.startKm = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("End KM", trip.endKm, (v) {
              trip.endKm = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Trip KM", trip.tripKm, (v) {
              trip.tripKm = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Max Speed", trip.maxSpeed, (v) {
              trip.maxSpeed = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Weight (GVW)", trip.weightGvw, (v) {
              trip.weightGvw = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Actual Diesel Ltrs", trip.actualDieselLtrs, (v) {
              trip.actualDieselLtrs = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Total Trip KM", trip.totalTripKm, (v) {
              trip.totalTripKm = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildNumberField("Actual FE (kmpl)", trip.actualFeKmpl, (v) {
              trip.actualFeKmpl = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildMultilineField("Issues Found / Driver Habits Corrected", trip.issuesFound ?? '', (v) {
              trip.issuesFound = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
            _buildMultilineField("Trial Remarks", trip.trialRemarks ?? '', (v) {
              trip.trialRemarks = v;
              controller.addOrUpdateTrip(tripIndex, trip);
            }),
          ],
        ),
      );
    });
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(String label, double? value, Function(double?) onChanged) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: (v) => onChanged(double.tryParse(v)),
      ),
    );
  }

  Widget _buildMultilineField(String label, String value, Function(String) onChanged) {
    return SizedBox(
      width: 600,
      child: TextField(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        maxLines: 3,
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, Function(DateTime) onPicked) {
    return SizedBox(
      width: 300,
      child: OutlinedButton(
        child: Text(date != null ? date.toIso8601String().substring(0, 10) : label),
        onPressed: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onPicked(picked);
          }
        },
      ),
    );
  }
}
