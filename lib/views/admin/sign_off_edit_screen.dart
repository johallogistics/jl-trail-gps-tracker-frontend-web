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
  final service = SignOffService(const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://jl-trail-gps-tracker-backend-production.up.railway.app'));

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

    c.editingId.value = so.id;
    if (so.driverId.isNotEmpty) {
      c.box.write('driverId', so.driverId); // persist driverId
    }
    // text controllers
    c.customerName.text = so.customerName ?? '';
    c.customerExpectedFE.text = so.customerExpectedFE?.toString() ?? '';
    c.beforeTrialsFE.text = so.beforeTrialsFE?.toString() ?? '';
    c.afterTrialsFE.text = so.afterTrialsFE?.toString() ?? '';
    c.issuesFoundDuringTrial.text = so.issuesFoundDuringTrial ?? '';
    c.trialRemarks.text = so.trialRemarks ?? '';
    c.customerRemarks.text = so.customerRemarks ?? '';

    // vehicle details
    c.vehicleDetails.tripDuration = so.customerVehicleDetails?.tripDuration ?? '';
    c.vehicleDetails.vehicleNo = so.customerVehicleDetails?.vehicleNo ?? '';
    c.vehicleDetails.saleDate = so.customerVehicleDetails?.saleDate ?? '';
    c.vehicleDetails.model = so.customerVehicleDetails?.model ?? '';
    c.vehicleDetails.application = so.customerVehicleDetails?.application ?? '';
    c.vehicleDetails.customerVerbatim = so.customerVehicleDetails?.customerVerbatim ?? '';
    c.vehicleDetails.tripRoute = so.customerVehicleDetails?.tripRoute ?? '';
    c.vehicleDetails.roadType = so.customerVehicleDetails?.roadType ?? '';
    c.vehicleDetails.vehicleCheckDate = so.customerVehicleDetails?.vehicleCheckDate ?? '';
    c.vehicleDetails.issuesFoundOnVehicleCheck = so.customerVehicleDetails?.issuesFoundOnVehicleCheck ?? '';

    // lists
    if (so.tripDetails.isNotEmpty) {
      c.tripDetails.assignAll(so.tripDetails);
    }
    if (so.participants.isNotEmpty) {
      c.participants.assignAll(so.participants);
    }
    if (so.photos.isNotEmpty) {
      c.photos.assignAll(so.photos);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Create Sign Off' : 'Edit #${widget.id}')),
      body: const SignOffForm(submitRole: 'ADMIN'),
    );
  }
}