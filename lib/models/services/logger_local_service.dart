import 'package:hive_ce/hive.dart';

import '../data/maperror/log_entry.dart';
import '../data/maperror/log_entry_hive.dart';

class LoggerLocalService {
  final Box<LogEntryHive> box;

  LoggerLocalService(this.box);

  Future<void> save(LogEntry entry) async {
    await box.add(
      LogEntryHive(
        action: entry.action,
        target: entry.target,
        entityId: entry.entityId,
        userId: entry.userId,
        data: entry.data,
        timestamp: entry.timestamp,
      ),
    );
  }

  List<LogEntry> load() {
    return box.values
        .map(
          (e) => LogEntry(
            action: e.action,
            target: e.target,
            entityId: e.entityId,
            userId: e.userId,
            data: Map<String, dynamic>.from(e.data ?? {}),
            timestamp: e.timestamp,
          ),
        )
        .toList();
  }
}
