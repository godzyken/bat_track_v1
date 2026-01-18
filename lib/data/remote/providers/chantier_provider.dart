import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/chantier/controllers/notifiers/chantier_notifier.dart';
import '../../../models/services/entity_service_registry.dart';
import '../../local/models/adapters/hive_entity_factory.dart';
import '../../local/models/entities/chantier_entity.dart';
import '../../local/models/index_model_extention.dart';

final chantierServiceProvider =
    buildLoggedEntitySyncServiceProvider<Chantier, ChantierEntity>(
      collectionName: 'chantiers',
      factory: ChantierEntityFactory(),
    );

final chantierAdvancedNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ChantierNotifier, Chantier?, String>(ChantierNotifier.new);
