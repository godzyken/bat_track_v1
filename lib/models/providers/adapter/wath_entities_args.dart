import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/core/unified_model.dart';
import '../../services/logged_entity_service.dart';

class WatchEntitiesArgs<T extends UnifiedModel> {
  final ProviderListenable<SafeAndLoggedEntityService<T>> serviceProvider;
  final String chantierId;

  const WatchEntitiesArgs({
    required this.serviceProvider,
    required this.chantierId,
  });
}
