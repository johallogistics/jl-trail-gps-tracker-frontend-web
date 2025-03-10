import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/shift_log_model.dart';

class ShiftLogController extends GetxController {
  var shiftLogs = <ShiftLog>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchShiftLogs();
  }

  void fetchShiftLogs() {
    // TODO: Fetch data from API and update shiftLogs
  }

  void deleteShiftLog(int id) {
    shiftLogs.removeWhere((log) => log.id == id);
  }
}