import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/data/maperror/log_entry.dart';

class LoggerCloudService {
  final FirebaseFirestore firestore;

  LoggerCloudService(this.firestore);

  Future<void> send(LogEntry entry) async {
    await firestore.collection('logs').add({
      'action': entry.action,
      'target': entry.target,
      'entityId': entry.entityId,
      'userId': entry.userId,
      'data': entry.data,
      'timestamp': entry.timestamp.toIso8601String(),
    });
  }
}
