import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/consolidated_form_submission_model.dart';
import '../repositories/consolidated_form_repository.dart';

class FormController extends GetxController {
  var isLoading = false.obs;
  final FormRepository _repository = FormRepository();

  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final masterDriverNameController = TextEditingController();
  final empCodeController = TextEditingController();
  final mobileNoController = TextEditingController();
  final customerDriverNameController = TextEditingController();
  final customerMobileNoController = TextEditingController();
  final licenseNoController = TextEditingController();

  var vehicleDetails = <VehicleDetail>[].obs;
  var competitorData = <VehicleDetail>[].obs;
  var selectedFieldsForCompetitor = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize vehicle details
    addVehicleDetail();
    // Initialize competitor details by copying the vehicle details
    addCompetitorData();
  }

  void addVehicleDetail() {
    var newVehicle = VehicleDetail(
      vehicleRegNo: TextEditingController(text: ''),
      brand: TextEditingController(text: ''),
      chassisNo: TextEditingController(text: ''),
      vehicleModel: TextEditingController(text: ''),
      wheelBase: TextEditingController(text: ''),
      atsType: TextEditingController(text: ''),
      emission: TextEditingController(text: ''),
      tyreBrand: TextEditingController(text: ''),
      application: TextEditingController(text: ''),
      gvwCarried: TextEditingController(text: ''),
      tripStartDate: TextEditingController(text: ''),
      startOdo: TextEditingController(text: ''),
      tripFinishDate: TextEditingController(text: ''),
      endOdo: TextEditingController(text: ''),
      startPlace: TextEditingController(text: ''),
      endPlace: TextEditingController(text: ''),
      totalTrailKms: TextEditingController(text: ''),
      fuelConsumed: TextEditingController(text: ''),
      adBlueConsumedCluster: TextEditingController(text: ''),
      didRegenerationHappen: false.obs,
      leadDistance: TextEditingController(text: ''),
      drivingSpeed: TextEditingController(text: ''),
      actualFeInBB: TextEditingController(text: ''),
    );
    vehicleDetails.add(newVehicle);
  }

  void addCompetitorData() {
    if (vehicleDetails.isNotEmpty) {
      var competitorVehicle = vehicleDetails.first;

      // Add competitor data based on the first vehicle
      competitorData.add(competitorVehicle);
    }
  }

  void toggleFieldCopy(String field, TextEditingController competitorController, TextEditingController originalController) {
    if (selectedFieldsForCompetitor[field] == true) {
      competitorController.text = originalController.text;
      competitorController.value = competitorController.value.copyWith(selection: TextSelection.collapsed(offset: competitorController.text.length));
    } else {
      competitorController.clear();
    }
  }

  Future<void> submitForm() async {
    try {
      isLoading(true);

      // Prepare data for submission
      FormSubmissionModel formData = FormSubmissionModel(
        location: locationController.text,
        date: dateController.text,
        masterDriverName: masterDriverNameController.text,
        empCode: empCodeController.text,
        mobileNo: mobileNoController.text,
        customerDriverName: customerDriverNameController.text,
        customerMobileNo: customerMobileNoController.text,
        licenseNo: licenseNoController.text,
        vehicleDetails: vehicleDetails.toList(),
        competitorData: competitorData.toList(),
      );

      // Assuming your FormRepository is set up for API calls
      bool success = await _repository.submitForm(formData);

      if (success) {
        print("Form submitted successfully");
        // Optionally show a success message to the user or navigate to a new screen
      } else {
        print("Form submission failed");
        // Optionally show an error message to the user
      }
    } catch (e) {
      print("Error submitting form: $e");
      // Optionally handle the error (show a message or retry)
    } finally {
      isLoading(false);
    }
  }
}
