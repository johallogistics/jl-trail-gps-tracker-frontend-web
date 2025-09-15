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
      c!.vehicleDetails.vehicleCheckDateController ??= TextEditingController(text: c!.vehicleDetails.vehicleCheckDate);
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
      c!.vehicleDetails.vehicleCheckDateController?.dispose();
      c!.vehicleDetails.saleDateController?.dispose();
      c!.vehicleDetails.saleDateController?.dispose();

      for (var td in c!.tripDetails) {
        td.controllers?.dispose();
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
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.bold),
          filled: true,
          fillColor: enabled ? Colors.blue[50] : Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctl, String label, void Function(String)? onChanged) {
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

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text('Trip ${td.tripNo == 6 ? 'Overall' : td.tripNo}'),
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
                    label: 'Trip Route',
                    onChanged: (v) => td.tripRoute = v.isEmpty ? null : v),
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
              _numField(td.controllers!.startKm, 'Start km', (v) => td.startKm = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.endKm, 'End km', (v) => td.endKm = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.tripKm, 'Trip km', (v) => td.tripKm = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.maxSpeed, 'Max speed', (v) => td.maxSpeed = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.weightGVW, 'Weight (GVW)', (v) => td.weightGVW = v.isEmpty ? null : double.tryParse(v)),
              _numField(td.controllers!.actualDiesel, 'Actual Diesel ltrs', (v) => td.actualDieselLtrs = v.isEmpty ? null : double.tryParse(v)),
              if (td.tripNo == 6) ...[
                _numField(td.controllers!.totalTripKm, 'Total Trip km', (v) => td.totalTripKm = v.isEmpty ? null : double.tryParse(v)),
                _numField(td.controllers!.actualFE, 'Actual FE (kmpl)', (v) => td.actualFE = v.isEmpty ? null : double.tryParse(v)),
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
            _styledTextField(controller: c!.customerName, label: 'Customer Name'),
            Row(
              children: [
                Expanded(child: _numField(c!.customerExpectedFE, 'Customer Expected FE', (_) {})),
                const SizedBox(width: 12),
                Expanded(child: _numField(c!.beforeTrialsFE, 'Before Trials FE', (_) {})),
                const SizedBox(width: 12),
                Expanded(child: _numField(c!.afterTrialsFE, 'After Trials FE', (_) {})),
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
            Text('Customer & Vehicle Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.tripDuration),
                    label: 'Trip Duration',
                    onChanged: (v) => c!.vehicleDetails.tripDuration = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.vehicleNo),
                    label: 'Vehicle no',
                    onChanged: (v) => c!.vehicleDetails.vehicleNo = v,
                  ),
                ),
                DateField(
                  controller: c!.vehicleDetails.saleDateController!,
                  label: 'Sale date',
                  onChanged: (v) => c!.vehicleDetails.saleDate = v,
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.model),
                    label: 'Model',
                    onChanged: (v) => c!.vehicleDetails.model = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.application),
                    label: 'Application',
                    onChanged: (v) => c!.vehicleDetails.application = v,
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.customerVerbatim),
                    label: 'Customer Verbatim',
                    maxLines: 2,
                    onChanged: (v) => c!.vehicleDetails.customerVerbatim = v,
                  ),
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.tripRoute),
                    label: 'Trip Route',
                    onChanged: (v) => c!.vehicleDetails.tripRoute = v,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.roadType),
                    label: 'Road type',
                    onChanged: (v) => c!.vehicleDetails.roadType = v,
                  ),
                ),
                DateField(
                  controller: c!.vehicleDetails.vehicleCheckDateController!,
                  label: 'Vehicle check date',
                  onChanged: (v) => c!.vehicleDetails.vehicleCheckDate = v,
                ),
                SizedBox(
                  width: 480,
                  child: _styledTextField(
                    controller: TextEditingController(text: c!.vehicleDetails.issuesFoundOnVehicleCheck),
                    label: 'Issues found on vehicle check',
                    maxLines: 2,
                    onChanged: (v) => c!.vehicleDetails.issuesFoundOnVehicleCheck = v,
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
            Text('Trials Details', style: Theme.of(context).textTheme.titleMedium),
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
              label: 'Issues found while trial / driver habits corrected',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _styledTextField(controller: c!.trialRemarks, label: 'Trial remarks', maxLines: 3),
            const SizedBox(height: 12),
            _styledTextField(controller: c!.customerRemarks, label: 'Customer Remarks', maxLines: 3),
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
            Get.snackbar('Missing', 'SignOffController not registered. Use binding or register service before navigation.',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Retry'),
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
                Get.snackbar("Submitted", "Trip submitted successfully");
              }
            } else {
              Get.snackbar("Saved", "Progress saved, continue later");
            }
          } else {
            final result = await c!.submit(createdByRole: 'ADMIN');
            if (result != null) {
              Get.offNamed('/signOffList', arguments: {"refresh": true, "updated": result});
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent[700],
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          c!.isSubmitting.value
              ? 'Submitting...'
              : c!.editingId.value == null
              ? 'Create (${widget.submitRole})'
              : widget.submitRole == 'DRIVER'
              ? 'Save / Submit'
              : 'Update (${widget.submitRole})',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If missing controller -> show helpful message and a retry button.
    if (_controllerMissing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sign Off')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('SignOff controller is not registered.',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                const Text(
                  'Register the SignOffService & SignOffController with GetX (binding or Get.put) before opening this page.',
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
                      Get.snackbar('Info', 'You can use a Binding or call Get.put(SignOffController(...)) before navigation.');
                    }
                  },
                  child: const Text('Retry / Info'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.submitRole == 'DRIVER' ? 'Sign Off (Driver)' : 'Sign Off (Admin)'),
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
            labelText: label,
            labelStyle: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.blue[50],
            suffixIcon: const Icon(Icons.calendar_today),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent[100]!, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent[700]!, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
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
