import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '../../services/debug_logger.dart';

void exportLogsImpl(BuildContext context, List<LogEntry> logs) {
  try {
    final logsString = logs.map((e) => '[${e.timestamp}] ${e.level}: ${e.message}\n${e.exception != null ? 'Exception: ${e.exception}\n' : ''}${e.stackTrace != null ? 'Stack Trace: ${e.stackTrace}\n' : ''}----------------------------------------').join('\n\n');
    
    final bytes = utf8.encode(logsString);
    final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/plain'));
    final url = web.URL.createObjectURL(blob);
    
    (web.document.createElement('a') as web.HTMLAnchorElement)
      ..href = url
      ..download = 'supabase_debug_logs_${DateTime.now().millisecondsSinceEpoch}.txt'
      ..click();
    
    web.URL.revokeObjectURL(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs exported successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to export logs: $e')),
    );
  }
}
