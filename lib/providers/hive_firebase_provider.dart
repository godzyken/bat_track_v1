import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/services/hive_service.dart';
import '../data/remote/services/firebase_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
