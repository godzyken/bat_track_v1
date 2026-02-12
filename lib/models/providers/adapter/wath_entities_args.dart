import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/hive_model.dart';
import '../../services/logged_entity_service.dart';

class WatchEntitiesArgs<M extends UnifiedModel, E extends HiveModel<M>> {
  final ProviderListenable<SafeAndLoggedEntityService<M, E>> serviceProvider;
  final String chantierId;

  const WatchEntitiesArgs({
    required this.serviceProvider,
    required this.chantierId,
  });
}
