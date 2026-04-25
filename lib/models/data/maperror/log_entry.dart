class LogEntry {
  final String action; // CREATE, UPDATE, DELETE, LOGIN...
  final String target; // project, chantier, user...
  final String? entityId; // ID de l'entité
  final String? userId; // qui a fait l'action
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const LogEntry({
    required this.action,
    required this.target,
    this.entityId,
    this.userId,
    this.data,
    required this.timestamp,
  });

  String get formatted => '$timestamp | $action on $target ($entityId)';
}
