// lib/views/widgets/sign_off_form.dart
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
  SignOffController? c;
  bool _controllerMissing = false;

  @override
  void initState() {
    super.initState();

    // Defensive finding of controller: if missing don't crash — show info UI instead.
    try {
      c = Get.find<SignOffController>();
    } catch (err) {
      // Controller not registered
      c = null;
      _controllerMissing = true;
      debugPrint('SignOffController not found: $err');
    }

    if (c != null) {
      // Initialize controllers for vehicle details if null (do not overwrite existing ones)
      c!.vehicleDetails.vehicleCheckDateController ??=
          TextEditingController(text: c!.vehicleDetails.vehicleCheckDate);
      c!.vehicleDetails.saleDateController ??=
          TextEditingController(text: c!.vehicleDetails.saleDate);

      // Initialize controllers for each trip (if not already)
      for (var td in c!.tripDetails) {
        td.controllers ??= TripControllers.fromTripDetail(td);
      }
    }
  }

  @override
  void dispose() {
    // Dispose what this form created (controllers usually live on SignOffController).
    if (c != null) {
      c!.vehicleDetails.vehicleCheckDateController?.dispose();
      c!.vehicleDetails.saleDateController?.dispose();

      for (var td in c!.tripDetails) {
        td.controllers?.dispose();
      }
    }
    super.dispose();
  }

  // Styled text field similar to DailyReportScreen style
  Widget _styledTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool enabled = true,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(color: Colors.blueAccent[700], fontSize: 15),
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          // translate label at render time
          labelText: label.tr,
          labelStyle: TextStyle(
              color: Colors.blueAccent[700], fontWeight: FontWeight.bold),
          filled: true,
          fillColor: enabled ? Colors.blue[50] : Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Colors.blueAccent[100]!, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Colors.grey[400]!, width: 1.5),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctl, String label,
      void Function(String)? onChanged) {
    return SizedBox(
      width: 140,
      child: _styledTextField(
        controller: ctl,
        label: label,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      ),
    );
  }

  Widget tripTile(TripDetail td) {
    // Ensure controllers exist
    td.controllers ??= TripControllers.fromTripDetail(td);

    final tripLabel = td.tripNo == 6
        ? '${'trip'.tr} ${'overall'.tr}' // 'overall' key may be added; fallback to 'Overall' if missing
        : '${'trip'.tr} ${td.tripNo}';

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text(tripLabel),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: _styledTextField(
                    controller: td.controllers!.tripRoute,
                    label: 'trip_route',
                    onChanged: (v) => td.tripRoute = v.isEmpty ? null : v),
              ),
              DateField(
                controller: td.controllers!.startDate,
                label: 'start_date',
                onChanged: (v) => td.tripStartDate = v,
              ),
              DateField(
                controller: td.controllers!.endDate,
                label: 'end_date',
                onChanged: (v) => td.tripEndDate = v,
              ),
              _numField(td.controllers!.startKm, 'start_km',
                      (v) => td.startKm = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.endKm, 'end_km',
                      (v) => td.endKm = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.tripKm, 'trip_km',
                      (v) => td.tripKm = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.maxSpeed, 'max_speed',
                      (v) => td.maxSpeed = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.weightGVW, 'weight_gvw',
                      (v) => td.weightGVW = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.actualDiesel, 'actual_diesel_ltrs',
                      (v) => td.actualDieselLtrs = v.isEmpty ? null : double.tryParse(v)),
              if (td.tripNo == 6) ...[
                _numField(td.controllers!.totalTripKm, 'total_trip_km',
                        (v) => td.totalTripKm = v.isEmpty ? null : double.tryParse(v)),
                _numField(td.controllers!.actualFE, 'actual_fe_kmpl',
                        (v) => td.actualFE = v.isEmpty ? null : double.tryParse(v)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDriverInfoCard() {
    if (c == null) return const SizedBox.shrink();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _styledTextField(
                controller: c!.customerName, label: 'customer_name'),
            Row(
              children: [
                Expanded(
                    child: _numField(
                        c!.customerExpectedFE, 'customer_expected_fe', (_) {})),
                const SizedBox(width: 12),
                Expanded(
                    child:
                    _numField(c!.beforeTrialsFE, 'before_trials_fe', (_) {})),
                const SizedBox(width: 12),
                Expanded(
                    child:
                    _numField(c!.afterTrialsFE, 'after_trials_fe', (_) {})),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard() {
    if (c == null) return const SizedBox.shrink();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('customer_vehicle_details'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller:
                    TextEditingController(text: c!.vehicleDetails.tripDuration),
                    label: 'trip_duration',
                    onChanged: (v) => c!.vehicleDetails.tripDuration = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller:
                    TextEditingController(text: c!.vehicleDetails.vehicleNo),
                    label: 'vehicle_no',
                    onChanged: (v) => c!.vehicleDetails.vehicleNo = v,
                  ),
                ),
                DateField(
                  controller: c!.vehicleDetails.saleDateController!,
                  label: 'sale_date',
                  onChanged: (v) => c!.vehicleDetails.saleDate = v,
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.model),
                    label: 'model',
                    onChanged: (v) => c!.vehicleDetails.model = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller:
                    TextEditingController(text: c!.vehicleDetails.application),
                    label: 'application',
                    onChanged: (v) => c!.vehicleDetails.application = v,
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller:
                    TextEditingController(text: c!.vehicleDetails.customerVerbatim),
                    label: 'customer_verbatim',
                    maxLines: 2,
                    onChanged: (v) => c!.vehicleDetails.customerVerbatim = v,
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.tripRoute),
                    label: 'trip_route',
                    onChanged: (v) => c!.vehicleDetails.tripRoute = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.roadType),
                    label: 'road_type',
                    onChanged: (v) => c!.vehicleDetails.roadType = v,
                  ),
                ),
                DateField(
                  controller: c!.vehicleDetails.vehicleCheckDateController!,
                  label: 'vehicle_check_date',
                  onChanged: (v) => c!.vehicleDetails.vehicleCheckDate = v,
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(
                        text: c!.vehicleDetails.issuesFoundOnVehicleCheck),
                    label: 'issues_found_on_vehicle_check',
                    maxLines: 2,
                    onChanged: (v) =>
                    c!.vehicleDetails.issuesFoundOnVehicleCheck = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsCard() {
    if (c == null) return const SizedBox.shrink();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('trials_details'.tr, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() => Column(children: c!.tripDetails.map(tripTile).toList())),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard() {
    if (c == null) return const SizedBox.shrink();
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _styledTextField(
              controller: c!.issuesFoundDuringTrial,
              label: 'issues_found_during_trial',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _styledTextField(controller: c!.trialRemarks, label: 'trial_remarks', maxLines: 3),
            const SizedBox(height: 12),
            _styledTextField(controller: c!.customerRemarks, label: 'customer_remarks', maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (c == null) {
      return ElevatedButton(
        onPressed: () {
          // Attempt to register controller in-place if missing (quick dev fallback).
          // NOTE: prefer registering with Binding or at higher level.
          if (!Get.isRegistered<SignOffController>()) {
            // Provide instruction: user should register the real controller with required dependencies
            Get.snackbar('Error'.tr, 'missing_controller_message'.tr,
                snackPosition: SnackPosition.BOTTOM);
          } else {
            setState(() {
              c = Get.find<SignOffController>();
              _controllerMissing = false;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent[700],
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 48),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('retry'.tr),
      );
    }

    return Obx(
          () => ElevatedButton(
        onPressed: c!.isSubmitting.value
            ? null
            : () async {
          if (widget.submitRole == 'DRIVER') {
            await c!.saveProgress();
            if (c!.canDriverSubmitNow()) {
              final result = await c!.submit(createdByRole: 'DRIVER');
              if (result != null) {
                Get.snackbar('Success'.tr, 'trip_submitted'.tr); // add trip_submitted in translations if desired
              }
            } else {
              Get.snackbar('Info'.tr, 'progress_saved'.tr); // add progress_saved key if desired
            }
          } else {
            final result = await c!.submit(createdByRole: 'ADMIN');
            if (result != null) {
              Get.offNamed('/signOffList',
                  arguments: {"refresh": true, "updated": result});
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent[700],
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 48),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          c!.isSubmitting.value
              ? 'submit'.tr
              : c!.editingId.value == null
              ? '${'create'.tr} (${widget.submitRole})'
              : widget.submitRole == 'DRIVER'
              ? 'save_submit'.tr
              : '${'update'.tr} (${widget.submitRole})',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If missing controller -> show helpful message and a retry button.
    if (_controllerMissing) {
      return Scaffold(
        appBar: AppBar(title: Text('sign_off_driver'.tr)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('missing_controller_message'.tr,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  'register_controller_instruction'.tr,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (Get.isRegistered<SignOffController>()) {
                      setState(() {
                        c = Get.find<SignOffController>();
                        _controllerMissing = false;
                      });
                    } else {
                      Get.snackbar('Info'.tr,
                          'register_controller_instruction'.tr);
                    }
                  },
                  child: Text('retry'.tr),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.submitRole == 'DRIVER'
            ? 'sign_off_driver'.tr
            : 'sign_off_admin'.tr),
        backgroundColor: Colors.blueAccent[700],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDriverInfoCard(),
              const SizedBox(height: 16),
              _buildVehicleCard(),
              const SizedBox(height: 16),
              _buildTripsCard(),
              const SizedBox(height: 16),
              _buildRemarksCard(),
              const SizedBox(height: 20),
              Center(child: _buildSubmitButton()),
              const SizedBox(height: 60),
            ],
          ),
        ),
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
            labelText: label.tr,
            labelStyle:
            TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.blue[50],
            suffixIcon: const Icon(Icons.calendar_today),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.blueAccent[100]!, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          ),
          onTap: () async {
            DateTime initial = DateTime.now();
            if (controller.text.isNotEmpty) {
              final parsed = DateTime.tryParse(controller.text);
              if (parsed != null) initial = parsed;
            }

            DateTime? picked = await showDatePicker(
              context: ctx,
              initialDate: initial,
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
