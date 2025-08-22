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

  var isSubmitting = false.obs;
  var editingId = RxnInt(); // null = new, non-null = update

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

  final tripDetails = <TripDetail>[for (int i = 1; i <= 6; i++) TripDetail(tripNo: i)].obs; // includes overall

  final photos = <Photo>[].obs;

  /// Build payload for saving/updating
  SignOff buildPayload(String createdByRole, {bool isFinal = false}) {
    return SignOff(
      id: editingId.value,
      customerName: customerName.text.trim(),
      customerExpectedFE: double.tryParse(customerExpectedFE.text),
      beforeTrialsFE: double.tryParse(beforeTrialsFE.text),
      afterTrialsFE: double.tryParse(afterTrialsFE.text),
      customerVehicleDetails: vehicleDetails,
      issuesFoundDuringTrial:
      issuesFoundDuringTrial.text.trim().isEmpty ? null : issuesFoundDuringTrial.text.trim(),
      trialRemarks: trialRemarks.text.trim().isEmpty ? null : trialRemarks.text.trim(),
      customerRemarks: customerRemarks.text.trim().isEmpty ? null : customerRemarks.text.trim(),
      createdByRole: createdByRole,
      tripDetails: tripDetails,
      participants: participants,
      photos: photos,
      isSubmitted: isFinal,
    );
  }

  /// Load existing draft or create a new one for DRIVER
  Future<void> loadOrCreateDraft() async {
    try {
      final draft = await api.getDraftForDriver(); // backend should return active draft or null
      if (draft != null) {
        _loadFromModel(draft);
      } else {
        final newDraft = await api.createDraftForDriver();
        _loadFromModel(newDraft);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load draft: $e');
    }
  }

  void _loadFromModel(SignOff data) {
    editingId.value = data.id;
    customerName.text = data.customerName ?? '';
    customerExpectedFE.text = data.customerExpectedFE?.toString() ?? '';
    beforeTrialsFE.text = data.beforeTrialsFE?.toString() ?? '';
    afterTrialsFE.text = data.afterTrialsFE?.toString() ?? '';
    vehicleDetails.copyFrom(data.customerVehicleDetails);
    issuesFoundDuringTrial.text = data.issuesFoundDuringTrial ?? '';
    trialRemarks.text = data.trialRemarks ?? '';
    customerRemarks.text = data.customerRemarks ?? '';
    tripDetails.assignAll(data.tripDetails ?? [for (int i = 1; i <= 6; i++) TripDetail(tripNo: i)]);
    participants.assignAll(data.participants ?? participants);
    photos.assignAll(data.photos ?? []);
  }

  /// Save progress (without submission)
  Future<void> saveProgress() async {
    if (editingId.value == null) return;
    try {
      final payload = buildPayload('DRIVER', isFinal: false);
      await api.update(editingId.value!, payload);
      Get.snackbar('Saved', 'Progress saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    }
  }

  /// Submit after completion
  Future<SignOff?> submit({required String createdByRole}) async {
    isSubmitting.value = true;
    try {
      final payload = buildPayload(createdByRole, isFinal: true); // returns SignOff

      late SignOff result;
      if (editingId.value == null) {
        result = await api.create(payload);
      } else {
        result = await api.submit(editingId.value!, payload, createdByRole);
      }

      Get.snackbar('Success', 'Trip submitted successfully');
      return result;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

}
