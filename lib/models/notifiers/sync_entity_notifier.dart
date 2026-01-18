import 'dart:async';

import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/core/unified_model.dart';
import '../services/logged_entity_service.dart';

abstract class SyncEntityNotifier<
  M extends UnifiedModel,
  E extends HiveModel<M>
>
    extends FamilyAsyncNotifier<M?, String> {
  // Cette méthode permettra à l'UI d'accéder au service si besoin
  SafeAndLoggedEntityService<M, E> get service;

  Future<void> updateEntity(M model);
  Future<void> refreshRemote();
}
