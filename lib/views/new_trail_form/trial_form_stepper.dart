import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/views/new_trail_form/participants_photo_form.dart';
import 'package:trail_tracker/views/new_trail_form/trip_form.dart';

import '../../controllers/new_trail_controller.dart';
import '../../repositories/trail_form_repo.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/trail_form_table_screen.dart';
import 'customer_details_form.dart';

class TrialFormStepper extends StatefulWidget {
  const TrialFormStepper({super.key});

  @override
  State<TrialFormStepper> createState() => _TrialFormStepperState();
}

class _TrialFormStepperState extends State<TrialFormStepper> {
  int _currentStep = 0;
  final controller = Get.find<TrialFormController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trial Form')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _next,
        onStepCancel: _prev,
        steps: _steps(),
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(onPressed: details.onStepContinue, child: Text(_isLast ? 'Submit' : 'Next')),
              if (_currentStep > 0)
                TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
            ],
          );
        },
      ),
    );
  }

  bool get _isLast => _currentStep == _steps().length - 1;

  void _next() async {
    if (_isLast) {
      // Submit
      final success = await TrialFormApiService.submitForm(controller.form.value);
      if (success) {
        Get.snackbar('Success', 'Successfully submitted form');
        controller.fetchTrialForms(); // Refresh table data
        Get.off(() => DashboardScreen(), arguments: 2); // Go back to Trails page
      } else {
        Get.snackbar('Error', 'Failed to submit form');
      }
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  List<Step> _steps() {
    return [
      Step(
        title: const Text('Customer'),
        content: CustomerDetailsForm(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Trips'),
        content: _buildTripsTabs(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Team & Photos'),
        content: ParticipantsPhotosForm(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Review'),
        content: _buildReview(),
        isActive: _currentStep >= 3,
        state: StepState.indexed,
      ),
    ];
  }

  Widget _buildTripsTabs() {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Trip-1'),
              Tab(text: 'Trip-2'),
              Tab(text: 'Trip-3'),
              Tab(text: 'Trip-4'),
              Tab(text: 'Trip-5'),
              Tab(text: 'Overall'),
            ],
          ),
          SizedBox(
            height: 600, // adjust as needed
            child: TabBarView(
              children: List.generate(6, (index) => TripForm(tripIndex: index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview() {
    return Obx(() {
      final json = controller.form.value.toJson();
      return SingleChildScrollView(
        child: Text(
          const JsonEncoder.withIndent('  ').convert(json),
          style: const TextStyle(fontFamily: 'Courier'),
        ),
      );
    });
  }
}
