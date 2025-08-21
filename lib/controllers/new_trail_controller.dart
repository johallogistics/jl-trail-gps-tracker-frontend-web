import 'package:get/get.dart';
import '../models/trial_form_new_model.dart';
import '../repositories/trail_form_repo.dart';

class TrialFormController extends GetxController {
  var form = TrialForm(participants: [], trips: [Trip()], photos: []).obs;
  var trialForms = <TrialForm>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrialForms();
  }

  Future<void> fetchTrialForms() async {
    print("----1----");
    isLoading.value = true;
    try {
      final data = await TrialFormApiService.fetchTrialForms(); // implement this method
      trialForms.value = data;
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTrialForm(int id) async {
    try {
      await TrialFormApiService.deleteTrialForm(id); // Implement this API call
      trialForms.removeWhere((form) => form.id == id);
      Get.snackbar("Success", "Trial form deleted");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete trial form");
    }
  }

  Future<void> updateTrialForm(TrialForm updatedForm) async {
    try {
      final success = await TrialFormApiService.updateTrialForm(updatedForm);
      if (success) {
        // update locally
        final index = trialForms.indexWhere((f) => f.id == updatedForm.id);
        if (index != -1) {
          trialForms[index] = updatedForm;
        }
        Get.snackbar("Success", "Trial Form updated");
      } else {
        Get.snackbar("Error", "Update failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update trial form");
    }
  }


  void updateField(String field, dynamic value) {
    form.update((f) {
      switch (field) {
        case 'customerName': f?.customerName = value; break;
        case 'customerExpectedFe': f?.customerExpectedFe = value; break;
        case 'beforeTrialsFe': f?.beforeTrialsFe = value; break;
        case 'afterTrialsFe': f?.afterTrialsFe = value; break;
        case 'tripDuration': f?.tripDuration = value; break;
        case 'vehicleNo': f?.vehicleNo = value; break;
        case 'saleDate': f?.saleDate = value; break;
        case 'model': f?.model = value; break;
        case 'application': f?.application = value; break;
        case 'customerVerbatim': f?.customerVerbatim = value; break;
        case 'tripRoute': f?.tripRoute = value; break;
        case 'issuesFoundOnVehicleCheck': f?.issuesFoundOnVehicleCheck = value; break;
        case 'roadType': f?.roadType = value; break;
        case 'vehicleCheckDate': f?.vehicleCheckDate = value; break;
        case 'customerRemarks': f?.customerRemarks = value; break;
      }
    });
  }

  void addOrUpdateTrip(int index, Trip trip) {
    final trips = form.value.trips ?? [];
    if (index < trips.length) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }
    form.update((f) => f?.trips = trips);
  }

  void ensureTripExists(int index) {
    final trips = form.value.trips ?? [];
    if (index >= trips.length) {
      trips.addAll(List.generate(index - trips.length + 1, (_) => Trip()));
      form.update((f) => f?.trips = trips);
    }
  }

  void addParticipant(ParticipantOld p) {
    form.update((f) {
      f?.participants ??= [];
      f!.participants!.add(p);
    });
  }

  void addPhoto(String url) {
    form.update((f) {
      f?.photos ??= [];
      f!.photos!.add(Photo(url: url));
    });
  }

  Map<String, dynamic> get json => form.value.toJson();
}