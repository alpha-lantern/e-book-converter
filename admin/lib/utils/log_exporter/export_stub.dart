import 'package:flutter/material.dart';
import '../../services/debug_logger.dart';

void exportLogsImpl(BuildContext context, List<LogEntry> logs) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Exporting logs is only supported on the Web right now.')),
  );
}
