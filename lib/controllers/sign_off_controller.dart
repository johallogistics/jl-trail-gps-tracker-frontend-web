// lib/controllers/sign_off_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../models/sign_off_models/participant.dart';
import '../models/sign_off_models/photo.dart';
import '../models/sign_off_models/sign_off.dart';
import '../models/sign_off_models/trip_details.dart';
import '../repositories/sign_off_services.dart';

class SignOffController extends GetxController {
  final SignOffService api;
  SignOffController(this.api);

  /// UI / State
  var isSubmitting = false.obs;
  var editingId = RxnInt();

  /// ✅ Trial completion checkbox flag
  final isTrialCompleted = false.obs;

  final box = GetStorage();

  /// Form controllers
  final customerName = TextEditingController();
  final customerExpectedFE = TextEditingController();
  final beforeTrialsFE = TextEditingController();
  final afterTrialsFE = TextEditingController();
  final issuesFoundDuringTrial = TextEditingController();
  final trialRemarks = TextEditingController();
  final customerRemarks = TextEditingController();

  /// Data models
  final vehicleDetails = CustomerVehicleDetails();

  final participants = <ParticipantSignOff>[
    ParticipantSignOff(role: 'CSM'),
    ParticipantSignOff(role: 'PC'),
    ParticipantSignOff(role: 'DRIVER'),
    ParticipantSignOff(role: 'CUSTOMER'),
  ].obs;

  final tripDetails = <TripDetail>[
    for (int i = 1; i <= 6; i++) TripDetail(tripNo: i)
  ].obs;

  final photos = <Photo>[].obs;

  /// ------------------------
  /// Payload Builder
  /// ------------------------
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

      /// 🔴 checkbox-driven submit
      isSubmitted: isFinal,
      trialCompleted: isTrialCompleted.value,

      driverId: (box.read('driverId') as String?) ??
          participants.firstWhereOrNull((p) => p.role == 'DRIVER')?.id?.toString() ??
          '',
    );
  }

  /// ------------------------
  /// Load / Draft
  /// ------------------------
  Future<void> loadOrCreateDraft() async {
    try {
      final draft = await api.getDraftForDriver();
      if (draft != null) {
        _loadFromModel(draft);
      } else {
        final newDraft = await api.createDraftForDriver(buildPayload('DRIVER'));
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

    isTrialCompleted.value = data.trialCompleted ?? false;

    tripDetails.assignAll(
      data.tripDetails?.isNotEmpty == true
          ? data.tripDetails!
          : [for (int i = 1; i <= 6; i++) TripDetail(tripNo: i)],
    );

    participants.assignAll(data.participants ?? participants);
    photos.assignAll(data.photos ?? []);
  }

  /// ------------------------
  /// Save / Submit
  /// ------------------------
  Future<void> saveProgress() async {
    try {
      if (editingId.value == null) {
        final draft = await api.createDraftForDriver(buildPayload('DRIVER'));
        editingId.value = draft.id;
      }
      await api.update(editingId.value!, buildPayload('DRIVER'));
      Get.snackbar('Saved', 'Progress saved');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<SignOff?> submit({required String createdByRole}) async {
    if (createdByRole == 'DRIVER' && !isTrialCompleted.value) {
      Get.snackbar('Incomplete', 'Please mark trial as completed');
      return null;
    }

    isSubmitting.value = true;
    try {
      if (editingId.value == null) {
        final draft = await api.createDraftForDriver(buildPayload(createdByRole));
        editingId.value = draft.id;
      }

      final payload = buildPayload(createdByRole, isFinal: true);
      final result = await api.submit(editingId.value!, payload, createdByRole);

      if (result != null) _loadFromModel(result);
      Get.snackbar('Success', 'Trip submitted');
      return result;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<SignOff?> updateAsAdmin() async {
    isSubmitting.value = true;
    try {
      if (editingId.value == null) return null;
      final result = await api.update(editingId.value!, buildPayload('ADMIN'));
      if (result != null) _loadFromModel(result);
      Get.snackbar('Success', 'Updated');
      return result;
    } finally {
      isSubmitting.value = false;
    }
  }
}
