import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/logged_entity_service.dart';

class WatchEntitiesArgs<T extends JsonModel> {
  final ProviderListenable<LoggedEntityService<T>> serviceProvider;
  final String chantierId;

  const WatchEntitiesArgs({
    required this.serviceProvider,
    required this.chantierId,
  });
}
