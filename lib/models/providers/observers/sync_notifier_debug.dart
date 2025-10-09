import 'package:flutter/foundation.dart';

import '../../../data/core/unified_model.dart';
import '../../../data/remote/services/firebase_storage_service.dart';
import '../../data/maperror/proxy.dart';
import '../../notifiers/sync_entity_notifier.dart';
import '../../services/entity_service.dart';

SyncEntityNotifier<T> debugNotifierProvider<T extends UnifiedModel>({
  required EntityService<T> entityService,
  required FirebaseStorageService storageService,
  required T initialState,
  bool autoSync = true,
  MethodFilter? logFilter,
  CallInterceptor? interceptor,
}) {
  // En debug, on wrap les services avec le DebugProxy
  final es =
      kDebugMode
          ? DebugProxy<EntityService<T>>(
            entityService,
            logFilter: logFilter,
            interceptor: interceptor,
          )
          : entityService;

  final ss =
      kDebugMode
          ? DebugProxy<FirebaseStorageService>(
            storageService,
            logFilter: logFilter,
            interceptor: interceptor,
          )
          : storageService;

  return SyncEntityNotifier<T>(
    entityService: es as EntityService<T>,
    storageService: ss as FirebaseStorageService,
    initialState: initialState,
    autoSync: autoSync,
  );
}
