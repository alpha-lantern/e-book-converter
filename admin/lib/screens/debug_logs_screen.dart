import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/debug_logger.dart';
import '../utils/log_exporter/log_exporter.dart';

class DebugLogsScreen extends ConsumerWidget {
  const DebugLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(debugLoggerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(debugLoggerProvider.notifier).clearLogs();
            },
            tooltip: 'Clear Logs',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => LogExporter.exportLogs(context, logs),
            tooltip: 'Export Logs to File',
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No logs found.'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isError = log.level == 'ERROR';
                final isWarning = log.level == 'WARN';
                
                final color = isError ? Colors.red : (isWarning ? Colors.orange : Colors.black87);

                return ExpansionTile(
                  title: Text(
                    '[${log.timestamp.toLocal()}] ${log.message}',
                    style: TextStyle(color: color, fontWeight: isError ? FontWeight.bold : FontWeight.normal),
                  ),
                  subtitle: Text('Level: ${log.level}'),
                  children: [
                    if (log.exception != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SelectableText(
                            'Exception:\n${log.exception}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    if (log.stackTrace != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SelectableText(
                            'Stack Trace:\n${log.stackTrace}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
