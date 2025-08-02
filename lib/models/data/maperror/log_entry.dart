class LogEntry {
  final DateTime timestamp;
  final String action;
  final String target;
  final dynamic data;

  LogEntry({
    required this.timestamp,
    required this.action,
    required this.target,
    this.data,
  });

  String get formatted =>
      '${timestamp.toIso8601String()} | $action @ $target\n${data ?? ""}';

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'action': action,
    'target': target,
    'data': data,
  };
}
