import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/hive_model.dart';
import '../../notifiers/sync_entity_notifier.dart';

typedef EntityNotifierProviderFamily<
  M extends UnifiedModel,
  E extends HiveModel<M>
> =
    AsyncNotifierProviderFamily<
      SyncEntityNotifier<M, E>, // On précise le type exact du Notifier ici
      M?, // Le type de donnée (AsyncValue<M?>)
      String // L'argument (ID)
    >;
