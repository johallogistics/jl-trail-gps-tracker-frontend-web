// lib/controllers/sign_off_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/sign_off_models/participant.dart';
import '../models/sign_off_models/photo.dart';
import '../models/sign_off_models/sign_off.dart';
import '../models/sign_off_models/trip_details.dart';
import '../repositories/sign_off_services.dart';

class SignOffController extends GetxController {
  final SignOffService api;
  SignOffController(this.api);

  // Form fields
  final customerName = TextEditingController();
  final customerExpectedFE = TextEditingController();
  final beforeTrialsFE = TextEditingController();
  final afterTrialsFE = TextEditingController();

  final vehicleDetails = CustomerVehicleDetails();

  final issuesFoundDuringTrial = TextEditingController();
  final trialRemarks = TextEditingController();
  final customerRemarks = TextEditingController();

  final participants = <ParticipantSignOff>[
    ParticipantSignOff(role: 'CSM'),
    ParticipantSignOff(role: 'PC'),
    ParticipantSignOff(role: 'DRIVER'),
    ParticipantSignOff(role: 'CUSTOMER'),
  ].obs;

  final tripDetails = <TripDetail>[ for (int i=1;i<=6;i++) TripDetail(tripNo: i) ].obs; // includes overall

  final photos = <Photo>[].obs;

  var isSubmitting = false.obs;

  SignOff buildPayload(String createdByRole) {
    return SignOff(
      customerName: customerName.text.trim(),
      customerExpectedFE: double.tryParse(customerExpectedFE.text),
      beforeTrialsFE: double.tryParse(beforeTrialsFE.text),
      afterTrialsFE: double.tryParse(afterTrialsFE.text),
      customerVehicleDetails: vehicleDetails,
      issuesFoundDuringTrial: issuesFoundDuringTrial.text.trim().isEmpty ? null : issuesFoundDuringTrial.text.trim(),
      trialRemarks: trialRemarks.text.trim().isEmpty ? null : trialRemarks.text.trim(),
      customerRemarks: customerRemarks.text.trim().isEmpty ? null : customerRemarks.text.trim(),
      createdByRole: createdByRole,
      tripDetails: tripDetails,
      participants: participants,
      photos: photos,
    );
  }

  Future<void> submit({required String createdByRole}) async {
    isSubmitting.value = true;
    try {
      final payload = buildPayload(createdByRole);
      await api.create(payload);
      Get.snackbar('Success', 'Form submitted');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally { isSubmitting.value = false; }
  }
}