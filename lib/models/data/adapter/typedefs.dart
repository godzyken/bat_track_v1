import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/core/unified_model.dart';
import '../../../data/local/models/index_model_extention.dart';
import '../../notifiers/sync_entity_notifier.dart';
import '../state_wrapper/wrappers.dart';

typedef QueryBuilder =
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query);

typedef EntityDetailBuilder<M, E> =
    Widget Function(
      BuildContext context,
      M entity,
      SyncEntityNotifier notifier,
      SyncedState<M> state,
    );
typedef FieldBuilder =
    Widget? Function(
      BuildContext context,
      String key,
      dynamic value,
      TextEditingController? controller,
      void Function(dynamic) onChanged,
      bool expertMode,
    );

typedef AsyncCallback<T> = Future<T> Function();
typedef Reader = T Function<T>(ProviderListenable<T> provider);
typedef OnEtapeSubmit = void Function(ChantierEtape etape);
typedef OnSubmit<T extends UnifiedModel> = void Function(T entity);
typedef FieldVisibility = bool Function(String key, dynamic value);
typedef FromJson<T> = T Function(Map<String, dynamic> json);
