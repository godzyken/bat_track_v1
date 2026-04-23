import 'package:hive_ce/hive.dart';

part 'log_entry_hive.g.dart';

@HiveType(typeId: 1)
class LogEntryHive extends HiveObject {
  @HiveField(0)
  String action;

  @HiveField(1)
  String target;

  @HiveField(2)
  String? entityId;

  @HiveField(3)
  String? userId;

  @HiveField(4)
  Map? data;

  @HiveField(5)
  DateTime timestamp;

  LogEntryHive({
    required this.action,
    required this.target,
    this.entityId,
    this.userId,
    this.data,
    required this.timestamp,
  });
}
