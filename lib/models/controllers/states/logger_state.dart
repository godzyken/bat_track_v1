import '../../data/maperror/log_entry.dart';

class LoggerState {
  final List<LogEntry> logs;
  final String? actionFilter;
  final String? targetFilter;
  final String? userFilter;

  const LoggerState({
    this.logs = const [],
    this.actionFilter,
    this.targetFilter,
    this.userFilter,
  });

  LoggerState copyWith({
    List<LogEntry>? logs,
    String? actionFilter,
    String? targetFilter,
    String? userFilter,
  }) {
    return LoggerState(
      logs: logs ?? this.logs,
      actionFilter: actionFilter,
      targetFilter: targetFilter,
      userFilter: userFilter,
    );
  }

  List<LogEntry> get filteredLogs {
    return logs.where((entry) {
      final matchAction =
          actionFilter == null || entry.action.contains(actionFilter!);
      final matchTarget =
          targetFilter == null || entry.target.contains(targetFilter!);
      final matchUser = userFilter == null || entry.userId == userFilter;

      return matchAction && matchTarget && matchUser;
    }).toList();
  }

  // 📊 Analytics simples
  Map<String, int> get actionsCount {
    final map = <String, int>{};
    for (final log in logs) {
      map[log.action] = (map[log.action] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get targetUsage {
    final map = <String, int>{};
    for (final log in logs) {
      map[log.target] = (map[log.target] ?? 0) + 1;
    }
    return map;
  }

  int get totalLogs => logs.length;
}
