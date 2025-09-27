import 'package:get/get.dart';
import '../models/shift_log_model.dart';
import 'admin/daily_report_controller.dart';

class ShiftLogController extends GetxController {
  var shiftLogs = <ShiftLog>[].obs;
  var selectedShiftLog = Rxn<ShiftLogResponse>(); // Holds a single shift log
  var isLoading = false.obs;
  final ShiftLogRepository _repository = ShiftLogRepository();
  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    fetchShiftLogs();
  }

  Future<void> fetchShiftLogs({bool force = false}) async {
    if (_isFetching && !force) {
      print('[ShiftLogController] fetchShiftLogs skipped — already fetching');
      return;
    }

    try {
      _isFetching = true;
      isLoading(true);
      print('[ShiftLogController] fetchShiftLogs START at ${DateTime.now().toIso8601String()}');

      final logs = await _repository.fetchShiftLogs();

      print('[ShiftLogController] fetched ${logs.length} from repo');

      // Dedupe by id (adjust field name if different)
      final Map<String, ShiftLog> uniqueMap = {};
      for (final log in logs) {
        if (log.id == null) {
          // if id can be null, fallback to some other key or include it anyway
          uniqueMap['null_${uniqueMap.length}'] = log;
        } else {
          uniqueMap[log.id.toString()] = log;
        }
      }
      final deduped = uniqueMap.values.toList();

      print('[ShiftLogController] deduped to ${deduped.length} items');

      // Replace the list atomically
      shiftLogs.assignAll(deduped);
    } catch (e, st) {
      print('[ShiftLogController] Error fetching shift logs: $e\n$st');
    } finally {
      isLoading(false);
      _isFetching = false;
      print('[ShiftLogController] fetchShiftLogs END at ${DateTime.now().toIso8601String()}');
    }
  }

  Future<void> addShiftLog(ShiftLog shiftLog) async {
    if (_isFetching) return;
    try {
      isLoading(true);
      final success = await _repository.postShiftLog(shiftLog);
      if (success) {
        await fetchShiftLogs(force: true); // force reload
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
        await fetchShiftLogs(force: true);
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
        await fetchShiftLogs(force: true);
      }
    } finally {
      isLoading(false);
    }
  }


}
