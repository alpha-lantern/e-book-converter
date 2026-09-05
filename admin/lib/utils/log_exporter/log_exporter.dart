import 'package:flutter/material.dart';
import '../../services/debug_logger.dart';

import 'export_stub.dart' if (dart.library.html) 'export_web.dart';

class LogExporter {
  static void exportLogs(BuildContext context, List<LogEntry> logs) {
    exportLogsImpl(context, logs);
  }
}
