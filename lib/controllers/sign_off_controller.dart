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

  /// UI / State
  var isSubmitting = false.obs;
  var editingId = RxnInt(); // null = new draft, non-null = existing

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
  ].obs; // last trip = overall

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
      issuesFoundDuringTrial: issuesFoundDuringTrial.text.trim().isEmpty
          ? null
          : issuesFoundDuringTrial.text.trim(),
      trialRemarks:
      trialRemarks.text.trim().isEmpty ? null : trialRemarks.text.trim(),
      customerRemarks: customerRemarks.text.trim().isEmpty
          ? null
          : customerRemarks.text.trim(),
      createdByRole: createdByRole,
      tripDetails: tripDetails,
      participants: participants,
      photos: photos,
      isSubmitted: isFinal,
      driverId: '1',
    );
  }

  /// ------------------------
  /// Load / Create Draft
  /// ------------------------
  Future<void> loadOrCreateDraft() async {
    try {
      final draft = await api.getDraftForDriver();
      if (draft != null) {
        _loadFromModel(draft);
      } else {
        final initial = buildPayload('DRIVER', isFinal: false);
        final newDraft = await api.createDraftForDriver(initial);
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
    tripDetails.assignAll(data.tripDetails ??
        [for (int i = 1; i <= 6; i++) TripDetail(tripNo: i)]);
    participants.assignAll(data.participants ?? participants);
    photos.assignAll(data.photos ?? []);
  }

  /// ------------------------
  /// Trip Utilities
  /// ------------------------
  bool _hasAnyTripData(TripDetail t) {
    return (t.tripRoute?.isNotEmpty ?? false) ||
        (t.tripStartDate?.isNotEmpty ?? false) ||
        (t.tripEndDate?.isNotEmpty ?? false) ||
        t.startKm != null ||
        t.endKm != null ||
        t.tripKm != null ||
        t.maxSpeed != null ||
        t.weightGVW != null ||
        t.actualDieselLtrs != null ||
        t.totalTripKm != null ||
        t.actualFE != null;
  }

  TripDetail? get latestEditedTrip {
    final edited = tripDetails
        .where((t) => (t.tripNo ?? 0) != 6 && _hasAnyTripData(t))
        .toList()
      ..sort((a, b) => (a.tripNo ?? 0).compareTo(b.tripNo ?? 0));
    return edited.isEmpty ? null : edited.last;
  }

  bool _isTripComplete(TripDetail t) {
    return t.tripRoute?.isNotEmpty == true &&
        t.tripStartDate?.isNotEmpty == true &&
        t.tripEndDate?.isNotEmpty == true &&
        t.startKm != null &&
        t.endKm != null &&
        t.tripKm != null;
  }

  /// Check if DRIVER can submit final trip
  bool canDriverSubmitNow() {
    // overall trip (tripNo 6) must be fully completed
    final overallTrip = tripDetails.firstWhere((t) => t.tripNo == 6);
    if (!_isTripComplete(overallTrip)) return false;

    // ensure no earlier trip is incomplete
    for (var t in tripDetails.where((t) => t.tripNo != 6)) {
      if (_hasAnyTripData(t) && !_isTripComplete(t)) return false;
    }

    return true;
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
      Get.snackbar('Saved', 'Progress saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    }
  }

  Future<SignOff?> submit({required String createdByRole}) async {
    if (!canDriverSubmitNow()) {
      Get.snackbar('Incomplete', 'Please complete all trip data before submitting');
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
