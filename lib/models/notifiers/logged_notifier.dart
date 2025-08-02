import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/maperror/log_entry.dart';

class LoggerNotifier extends StateNotifier<List<LogEntry>> {
  LoggerNotifier() : super([]);

  String? actionFilter;
  String? targetFilter;

  void log(LogEntry entry) {
    state = [...state, entry];
    developer.log('[LOG] ${entry.formatted}'); // Console
  }

  void clear() => state = [];

  List<LogEntry> get filtered =>
      state.where((entry) {
        final matchAction =
            actionFilter == null || entry.action.contains(actionFilter!);
        final matchTarget =
            targetFilter == null || entry.target.contains(targetFilter!);
        return matchAction && matchTarget;
      }).toList();

  void setFilters({String? action, String? target}) {
    actionFilter = action?.isNotEmpty == true ? action : null;
    targetFilter = target?.isNotEmpty == true ? target : null;
  }
}

extension LoggerExport on LoggerNotifier {
  String exportJson() {
    final filteredLogs = this.filtered;
    final list =
        filteredLogs
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

final loggerNotifierProvider =
    StateNotifierProvider<LoggerNotifier, List<LogEntry>>(
      (ref) => LoggerNotifier(),
    );

final filteredLogsProvider = Provider<List<LogEntry>>((ref) {
  return ref.watch(loggerNotifierProvider.notifier).filtered;
});
