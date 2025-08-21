import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sign_off_controller.dart';
import '../../models/sign_off_models/sign_off.dart';
import '../../repositories/sign_off_services.dart';
import '../widgets/sign_off_form.dart';

class SignOffEditScreen extends StatefulWidget {
  final int? id; // if null -> create
  const SignOffEditScreen({super.key, this.id});

  @override
  State<SignOffEditScreen> createState() => _SignOffEditScreenState();
}

class _SignOffEditScreenState extends State<SignOffEditScreen> {
  final service = SignOffService(const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000'));

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SignOffController>()) {
      Get.put(SignOffController(service));
    }
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    final c = Get.find<SignOffController>();
    final data = await service.getById(widget.id!);
    final so = SignOff.fromJson(data);
    c.customerName.text = so.customerName;
    c.customerExpectedFE.text = so.customerExpectedFE?.toString() ?? '';
    c.beforeTrialsFE.text = so.beforeTrialsFE?.toString() ?? '';
    c.afterTrialsFE.text = so.afterTrialsFE?.toString() ?? '';
    c.issuesFoundDuringTrial.text = so.issuesFoundDuringTrial ?? '';
    c.trialRemarks.text = so.trialRemarks ?? '';
    c.customerRemarks.text = so.customerRemarks ?? '';

    // replace lists
    c.tripDetails.assignAll(so.tripDetails);
    c.participants.assignAll(so.participants);
    c.photos.assignAll(so.photos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Create Sign Off' : 'Edit #${widget.id}')),
      body: const SignOffForm(submitRole: 'ADMIN'),
    );
  }
}