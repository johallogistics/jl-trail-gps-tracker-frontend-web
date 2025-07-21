import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/new_trail_controller.dart';
import '../models/trial_form_new_model.dart';

class EditTrialFormScreen extends StatefulWidget {
  final TrialForm form;
  const EditTrialFormScreen({super.key, required this.form});

  @override
  State<EditTrialFormScreen> createState() => _EditTrialFormScreenState();
}

class _EditTrialFormScreenState extends State<EditTrialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<TrialFormController>();

  late TextEditingController customerNameCtrl;
  late TextEditingController vehicleNoCtrl;
  late TextEditingController modelCtrl;
  late TextEditingController applicationCtrl;
  late TextEditingController expectedFeCtrl;

  @override
  void initState() {
    super.initState();
    customerNameCtrl = TextEditingController(text: widget.form.customerName ?? '');
    vehicleNoCtrl = TextEditingController(text: widget.form.vehicleNo ?? '');
    modelCtrl = TextEditingController(text: widget.form.model ?? '');
    applicationCtrl = TextEditingController(text: widget.form.application ?? '');
    expectedFeCtrl = TextEditingController(
        text: widget.form.customerExpectedFe?.toString() ?? '');
  }

  @override
  void dispose() {
    customerNameCtrl.dispose();
    vehicleNoCtrl.dispose();
    modelCtrl.dispose();
    applicationCtrl.dispose();
    expectedFeCtrl.dispose();
    super.dispose();
  }

  void saveForm() {
    if (_formKey.currentState!.validate()) {
      final updatedForm = widget.form.copyWith(
        customerName: customerNameCtrl.text,
        vehicleNo: vehicleNoCtrl.text,
        model: modelCtrl.text,
        application: applicationCtrl.text,
        customerExpectedFe: double.tryParse(expectedFeCtrl.text),
      );

      controller.updateTrialForm(updatedForm);
      Get.back(); // Close the screen after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Trial Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: customerNameCtrl,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: vehicleNoCtrl,
                decoration: const InputDecoration(labelText: 'Vehicle No'),
              ),
              TextFormField(
                controller: modelCtrl,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextFormField(
                controller: applicationCtrl,
                decoration: const InputDecoration(labelText: 'Application'),
              ),
              TextFormField(
                controller: expectedFeCtrl,
                decoration: const InputDecoration(labelText: 'Expected FE (km/l)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: saveForm,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
