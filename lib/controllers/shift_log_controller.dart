import 'package:get/get.dart';
import '../models/shift_log_model.dart';
import 'admin/daily_report_controller.dart';

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
    print("Inside fetching shift logs");

    try {
      isLoading(true);
      var logs = await _repository.fetchShiftLogs();
      print("Fetched shift logs: $logs");

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
        fetchShiftLogs(); // Refresh full list from server
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

  Future<void> editShiftLog(ShiftLog log) async {
    try {
      isLoading(true);
      final success = await _repository.updateShiftLog(log);
      if (success) {
        fetchShiftLogs(); // refresh UI with updated list
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteShiftLog(int id) async {
    print("Delete Called");
    try {
      isLoading(true);
      final success = await _repository.deleteShiftLog(id);
      if (success) {
        print("Delete Success");
        fetchShiftLogs(); // refresh UI
      }
    } finally {
      isLoading(false);
    }
  }


}
