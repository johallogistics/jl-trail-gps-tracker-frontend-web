import 'package:get/get.dart';
import '../models/shift_log_model.dart';
import 'admin/daily_report_controller.dart';

class ShiftLogController extends GetxController {
  var shiftLogs = <ShiftLog>[].obs;
  var selectedShiftLog = Rxn<ShiftLogResponse>(); // Holds a single shift log
  var isLoading = false.obs;
  final ShiftLogRepository _repository = ShiftLogRepository();
  bool _isFetching = false;

  // Pagination
  var page = 1.obs;
  var pageSize = 20.obs;
  var total = 0.obs;
  var totalPages = 1.obs;

  // Filters
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var driverQuery = ''.obs;


  @override
  void onInit() {
    super.onInit();
    fetchShiftLogs();
  }

  Future<void> fetchShiftLogs({bool force = false}) async {
    if (_isFetching && !force) return;
    try {
      _isFetching = true;
      isLoading(true);

      final pageResp = await _repository.fetchShiftLogs(
        page: page.value,
        pageSize: pageSize.value,
        start: startDate.value,
        end: endDate.value,
        driver: driverQuery.value,
      );

      shiftLogs.assignAll(pageResp.items);
      page.value = pageResp.page;
      pageSize.value = pageResp.pageSize;
      total.value = pageResp.total;
      totalPages.value = pageResp.totalPages;
    } catch (e) {
      // handle/log
      rethrow;
    } finally {
      isLoading(false);
      _isFetching = false;
    }
  }

  void setDriverQuery(String q) {
    driverQuery.value = q;
    page.value = 1;
    fetchShiftLogs(force: true);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    page.value = 1;
    fetchShiftLogs(force: true);
  }

  void setPageSize(int size) {
    pageSize.value = size;
    page.value = 1;
    fetchShiftLogs(force: true);
  }

  void nextPage() {
    if (page.value < totalPages.value) {
      page.value++;
      fetchShiftLogs(force: true);
    }
  }

  void prevPage() {
    if (page.value > 1) {
      page.value--;
      fetchShiftLogs(force: true);
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
