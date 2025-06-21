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

    RxBool sunVisor = false.obs;
    RxBool bumperCorner = false.obs;
    RxBool bumperSpoiler = false.obs;
    RxBool bumperFootMesh = false.obs;
    RxBool windDeflector = false.obs;
    RxBool competitorSunVisor = false.obs;
    RxBool competitorBumperCorner = false.obs;
    RxBool competitorBumperSpoiler = false.obs;
    RxBool competitorBumperFootMesh = false.obs;
    RxBool competitorWindDeflector = false.obs;

  final expectedFeByCustomer = TextEditingController();
  final feAdvDisadv = TextEditingController();
  final referenceFeCustomerFleet = TextEditingController();

  RxBool dealerDriverAccompanied = false.obs;
  RxBool customerDriverAccompanied = false.obs;
  RxBool cruiseControlUsed = false.obs;

  final highwayPercentage = TextEditingController();
  final ghatRoadPercentage = TextEditingController();
  final singleRoadPercentage = TextEditingController();
  final trafficRoadPercentage = TextEditingController();
  final poorRoadPercentage = TextEditingController();
  final noRoadPercentage = TextEditingController();


  @override
  void onInit() {
    super.onInit();
    // Initialize vehicle details
    addVehicleDetail();
    // Initialize competitor details by copying the vehicle details
    initializeCompetitorData();
  }

  void addVehicleDetail() {
    var newVehicle = VehicleDetail(
      vehicleRegNo: TextEditingController(),
      brand: TextEditingController(),
      chassisNo: TextEditingController(),
      vehicleModel: TextEditingController(),
      wheelBase: TextEditingController(),
      atsType: TextEditingController(),
      emission: TextEditingController(),
      tyreBrand: TextEditingController(),
      application: TextEditingController(),
      gvwCarried: TextEditingController(),
      tripStartDate: TextEditingController(),
      startOdo: TextEditingController(),
      tripFinishDate: TextEditingController(),
      endOdo: TextEditingController(),
      startPlace: TextEditingController(),
      endPlace: TextEditingController(),
      totalTrailKms: TextEditingController(),
      fuelConsumed: TextEditingController(),
      adBlueConsumedCluster: TextEditingController(),
      didRegenerationHappen: false.obs,
      leadDistance: TextEditingController(),
      drivingSpeed: TextEditingController(),
      actualFeInBB: TextEditingController(),
    );
    vehicleDetails.add(newVehicle);
  }

  void initializeCompetitorData() {
    competitorData.assignAll(vehicleDetails.map((v) => v.copy()).toList());
  }

  // void toggleFieldCopy(String field, TextEditingController competitorController, TextEditingController originalController) {
  //   if (selectedFieldsForCompetitor[field] == true) {
  //     competitorController.text = originalController.text;
  //     competitorController.value = competitorController.value.copyWith(
  //       selection: TextSelection.collapsed(offset: competitorController.text.length),
  //     );
  //   } else {
  //     competitorController.clear();
  //   }
  // }

  Future<void> submitForm(List<String> imageUrls) async {
    try {
      isLoading(true);
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
        imageVideoUrls: imageUrls,
      );
      print("FORM DATA::: ${formData}");
      // Submit form
      bool success = await _repository.submitForm(formData);

      if (success) {
        print("Form submitted successfully");
      } else {
        print("Form submission failed");
      }
    } catch (e) {
      print("Error submitting form: $e");
    } finally {
      isLoading(false);
    }
  }
}
