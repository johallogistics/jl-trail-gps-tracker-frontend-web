// lib/views/widgets/sign_off_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    final box = GetStorage();

    // Defensive finding of controller: if missing don't crash — show info UI instead.
    try {
      c = Get.find<SignOffController>();
      c!.loadOrCreateDraft();
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
    double? width,
  }) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.tr,
              style: TextStyle(
                  color: Colors.blueAccent[700], fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(color: Colors.blueAccent[700], fontSize: 15),
            cursorColor: Colors.blueAccent,
            decoration: InputDecoration(
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
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
            ),
          ),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return child;
  }

  Widget _numField(
      TextEditingController ctl, String label, void Function(String)? onChanged,
      {double? width}) {
    return SizedBox(
      width: width ?? 140,
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
        ? '${'trip'.tr} ${'overall'.tr}'
        : '${'trip'.tr} ${td.tripNo}';

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      title: ConstrainedBox(
        constraints:
            const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
        child: Text(
          tripLabel,
          softWrap: true,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
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
              _numField(
                  td.controllers!.actualDiesel,
                  'actual_diesel_ltrs',
                  (v) => td.actualDieselLtrs =
                      v.isEmpty ? null : double.tryParse(v)),
              if (td.tripNo == 6) ...[
                _numField(
                    td.controllers!.totalTripKm,
                    'total_trip_km',
                    (v) =>
                        td.totalTripKm = v.isEmpty ? null : double.tryParse(v)),
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                    width: 220,
                    child: _numField(
                        c!.customerExpectedFE, 'customer_expected_fe', (_) {})),
                SizedBox(
                    width: 220,
                    child: _numField(
                        c!.beforeTrialsFE, 'before_trials_fe', (_) {})),
                SizedBox(
                    width: 220,
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
                    controller: TextEditingController(
                        text: c!.vehicleDetails.tripDuration),
                    label: 'trip_duration',
                    onChanged: (v) => c!.vehicleDetails.tripDuration = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(
                        text: c!.vehicleDetails.vehicleNo),
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
                    controller:
                        TextEditingController(text: c!.vehicleDetails.model),
                    label: 'model',
                    onChanged: (v) => c!.vehicleDetails.model = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(
                        text: c!.vehicleDetails.application),
                    label: 'application',
                    onChanged: (v) => c!.vehicleDetails.application = v,
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(
                        text: c!.vehicleDetails.customerVerbatim),
                    label: 'customer_verbatim',
                    maxLines: 2,
                    onChanged: (v) => c!.vehicleDetails.customerVerbatim = v,
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(
                        text: c!.vehicleDetails.tripRoute),
                    label: 'trip_route',
                    onChanged: (v) => c!.vehicleDetails.tripRoute = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller:
                        TextEditingController(text: c!.vehicleDetails.roadType),
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
            Text('trials_details'.tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Obx(() => Column(children: c!.tripDetails.map(tripTile).toList())),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialCompletionCheckbox() {
    if (c == null || widget.submitRole != 'DRIVER') {
      return const SizedBox.shrink();
    }

    return Obx(
          () => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox container (styled)
              Container(
                decoration: BoxDecoration(
                  color: c!.isTrialCompleted.value
                      ? Colors.blueAccent.withOpacity(0.15)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: c!.isTrialCompleted.value
                        ? Colors.blueAccent
                        : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Checkbox(
                  value: c!.isTrialCompleted.value,
                  onChanged: (v) => c!.isTrialCompleted.value = v ?? false,
                  activeColor: Colors.blueAccent[700],
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: InkWell(
                  onTap: () =>
                  c!.isTrialCompleted.value = !c!.isTrialCompleted.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trial Completed Confirmation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent[700],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'I confirm that the vehicle trial has been fully completed '
                            'and all trip details entered correctly.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blueAccent[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Required before final submission',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueAccent[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
            _styledTextField(
                controller: c!.trialRemarks,
                label: 'trial_remarks',
                maxLines: 3),
            const SizedBox(height: 12),
            _styledTextField(
                controller: c!.customerRemarks,
                label: 'customer_remarks',
                maxLines: 3),
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

                  if (!c!.isTrialCompleted.value) {
                    Get.snackbar(
                      'Incomplete',
                      'Please mark trial as completed before submitting',
                    );
                    return;
                  }

                  final result = await c!.submit(createdByRole: 'DRIVER');
                  if (result != null) {
                    Get.snackbar('Success', 'Trip submitted');
                  }
                } else {
                  final result = await c!.updateAsAdmin();
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
                Text('register_controller_instruction'.tr,
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (Get.isRegistered<SignOffController>()) {
                      setState(() {
                        c = Get.find<SignOffController>();
                        _controllerMissing = false;
                      });
                    } else {
                      Get.snackbar(
                          'Info'.tr, 'register_controller_instruction'.tr);
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
              _buildTrialCompletionCheckbox(),
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
/// DateField: multi-line readOnly field so long text is always visible (no ellipsis)
/// Multi-line, always-visible date display with calendar picker.
/// Shows label above the field and a wrapping text area (no ellipsis).
class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String) onChanged;
  final double? width; // optional

  const DateField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.width,
  });

  Future<void> _pickDate(BuildContext ctx) async {
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(controller.text);
      if (parsed != null) initial = parsed;
    }

    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final val = picked.toIso8601String().split('T').first;
      controller.text = val;
      onChanged(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = InkWell(
      onTap: () => _pickDate(context),
      child: Container(
        decoration: BoxDecoration(
          // match your other fields visual style
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.shade100, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AnimatedBuilder listens to controller and rebuilds when text changes
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final text = controller.text;
                  if (text.isEmpty) {
                    return Text(
                      '-', // placeholder
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    );
                  }
                  return SelectableText(
                    text,
                    maxLines: null, // allow wrapping
                    textAlign: TextAlign.left,
                    style:
                        TextStyle(fontSize: 16, color: Colors.blueAccent[700]),
                  );
                },
              ),
            ),

            const SizedBox(width: 8),
            // calendar icon (tappable)
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Icon(Icons.calendar_today, color: Colors.blueAccent[700]),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: width ?? 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always-visible label above (localized)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent[700],
              ),
            ),
          ),
          // Field that shows wrapping text; outer InkWell handles taps
          field,
        ],
      ),
    );
  }
}
