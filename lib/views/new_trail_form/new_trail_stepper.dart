import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'trip_form.dart';

class NewTrailStepper extends StatefulWidget {
  const NewTrailStepper({super.key});

  @override
  State<NewTrailStepper> createState() => _NewTrailStepperState();
}

class _NewTrailStepperState extends State<NewTrailStepper> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: currentStep,
      onStepContinue: () => setState(() => currentStep += 1),
      onStepCancel: () => setState(() => currentStep = (currentStep - 1).clamp(0, 10)),
      steps: [
        Step(title: const Text("Trip 1"), content: TripForm(tripIndex: 0)),
        Step(title: const Text("Trip 2"), content: TripForm(tripIndex: 1)),
        Step(title: const Text("Trip 3"), content: TripForm(tripIndex: 2)),
        Step(title: const Text("Trip 4"), content: TripForm(tripIndex: 3)),
        Step(title: const Text("Trip 5"), content: TripForm(tripIndex: 4)),
        Step(title: const Text("Trip Overall"), content: TripForm(tripIndex: 5)),
      ],
    );
  }
}