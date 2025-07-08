// lib/utils/file_download_service.dart

import 'package:flutter/foundation.dart';
import '../../models/shift_log_model.dart';

// Conditional import
import 'file_download_service_stub.dart'
if (dart.library.html) 'file_download_service_web.dart'
if (dart.library.io) 'file_download_service_mobile.dart';

/// This will route to the correct implementation
void exportShiftLogsToCsv(List<ShiftLog> logs) {
  exportShiftLogsToCsvImpl(logs);
}
