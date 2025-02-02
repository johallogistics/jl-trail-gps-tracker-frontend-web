import 'package:get/get.dart';
import '../models/shift_log_model.dart';
import '../repositories/sift_log_repository.dart';

class ShiftLogController extends GetxController {
  var shiftLogs = <ShiftLog>[].obs;
  var selectedShiftLog = Rxn<ShiftLogResponse>(); // Holds a single shift log
  var isLoading = false.obs;
  final ShiftLogRepository _repository = ShiftLogRepository();

  @override
  void onInit() {
    super.onInit();
    fetchShiftLogs();
  }

  void fetchShiftLogs() async {
    try {
      isLoading(true);
      var logs = await _repository.fetchShiftLogs();
      shiftLogs.assignAll(logs);
    } catch (e) {
      print("Error fetching shift logs: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addShiftLog(ShiftLog shiftLog) async {
    try {
      isLoading(true);
      bool success = await _repository.postShiftLog(shiftLog);
      if (success) {
        shiftLogs.add(shiftLog);
      }
    } catch (e) {
      print("Error adding shift log: $e");
    } finally {
      isLoading(false);
    }
  }

  void fetchShiftLogById(String id) async {
    try {
      isLoading(true);
      var log = await _repository.fetchShiftLogById(id);
      print("log:: ${log?.payload?.coDriverName}");
      selectedShiftLog.value = log;
    } catch (e) {
      print("Error fetching shift log by ID: $e");
    } finally {
      isLoading(false);
    }
  }

}
