import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/states/logger_state.dart';
import '../data/maperror/log_entry.dart';
import '../services/logger_local_service.dart';

class LoggerNotifier extends Notifier<LoggerState> {
  final _listeners = <void Function(LogEntry)>[];
  late LoggerLocalService localService;

  List<LogEntry> get _filterLogs => [];

  @override
  LoggerState build() {
    final logs = localService.load();
    developer.log('logs: $logs');
    _filterLogs.addAll(logs);
    return LoggerState(logs: logs);
  }

  // 📨 EVENT BUS
  void subscribe(void Function(LogEntry) listener) {
    _listeners.add(listener);
  }

  void unsubscribe(void Function(LogEntry) listener) {
    _listeners.remove(listener);
  }

  void _notify(LogEntry entry) {
    for (final listener in _listeners) {
      listener(entry);
    }
  }

  // 🧾 LOG
  void log(LogEntry entry) {
    state = state.copyWith(logs: [...state.logs, entry]);
    localService.save(entry);
    _notify(entry); // 🔥 event bus déclenché
  }

  void clear() {
    state = state.copyWith(logs: []);
    _filterLogs.clear();
  }

  void setFilters({String? action, String? target, String? user}) {
    state = state.copyWith(
      actionFilter: action?.isNotEmpty == true ? action : null,
      targetFilter: target?.isNotEmpty == true ? target : null,
      userFilter: user?.isNotEmpty == true ? user : null,
    );
  }
}

extension LoggerExport on LoggerNotifier {
  String exportJson() {
    final filteredLogs = _filterLogs;
    final list = filteredLogs
        .map(
          (log) => {
            'action': log.action,
            'target': log.target,
            'data': log.data,
            'timestamp': log.timestamp.toIso8601String(),
          },
        )
        .toList();
    return jsonEncode(list);
  }
}

final loggerNotifierProvider = NotifierProvider<LoggerNotifier, LoggerState>(
  LoggerNotifier.new,
);

final filteredLogsProvider = Provider<List<LogEntry>>((ref) {
  return ref.watch(loggerNotifierProvider).filteredLogs;
});
