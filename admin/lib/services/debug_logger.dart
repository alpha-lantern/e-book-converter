import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config.dart';

part 'debug_logger.g.dart';

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;
  final String? exception;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.exception,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level,
        'message': message,
        'exception': exception,
        'stackTrace': stackTrace,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: json['level'],
      message: json['message'],
      exception: json['exception'],
      stackTrace: json['stackTrace'],
    );
  }
}

@Riverpod(keepAlive: true)
class DebugLogger extends _$DebugLogger {
  static const int _maxLogs = 500;
  static const String _prefsKey = 'debug_logs';

  @override
  List<LogEntry> build() {
    if (!AppConfig.enableDebugLogs) return [];
    _loadLogs();
    return [];
  }

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList(_prefsKey);
      if (logsJson != null) {
        final loadedLogs = logsJson
            .map((e) => LogEntry.fromJson(jsonDecode(e)))
            .toList();
        state = [...state, ...loadedLogs].take(_maxLogs).toList();
      }
    } catch (e) {
      debugPrint('Failed to load debug logs: $e');
    }
  }

  Timer? _debounceTimer;

  Future<void> log(String level, String message, {Object? error, StackTrace? stackTrace}) async {
    if (!AppConfig.enableDebugLogs) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      exception: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    final updatedLogs = [entry, ...state];
    if (updatedLogs.length > _maxLogs) {
      updatedLogs.removeLast();
    }
    
    state = updatedLogs;

    // Persist with debounce
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final logsToSave = state;
        final logsJson = logsToSave.map((e) => jsonEncode(e.toJson())).toList();
        await prefs.setStringList(_prefsKey, logsJson);
      } catch (e) {
        debugPrint('Failed to save debug logs: $e');
      }
    });
  }

  void logInfo(String message) => log('INFO', message);
  void logWarning(String message, {Object? error, StackTrace? stackTrace}) => log('WARN', message, error: error, stackTrace: stackTrace);
  void logError(String message, {Object? error, StackTrace? stackTrace}) => log('ERROR', message, error: error, stackTrace: stackTrace);

  Future<void> clearLogs() async {
    _debounceTimer?.cancel();
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
