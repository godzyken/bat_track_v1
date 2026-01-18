import 'package:bat_track_v1/data/local/models/entities/index_entity_extention.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterventionListNotifier
    extends EntityListNotifier<Intervention, InterventionEntity> {}

final interventionListProvider =
    AsyncNotifierProvider<InterventionListNotifier, List<Intervention>>(
      () => InterventionListNotifier(),
    );
