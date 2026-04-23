import 'package:bat_track_v1/core/services/unified_entity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/entity_providers.dart';
import '../../../../data/local/models/entities/intervention_entity.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/controllers/states/intervention_state.dart';

class InterventionNotifier extends AsyncNotifier<InterventionState> {
  late final UnifiedEntityService<Intervention, InterventionEntity>
  interventionService;

  @override
  Future<InterventionState> build() async {
    interventionService = ref.read(interventionServiceProvider);

    final interventions = await interventionService.getAllRemote();

    final Map<String, int> stats = {'Terminée': 0, 'En cours': 0, 'Annulée': 0};

    for (final i in interventions) {
      stats[i.statut] = (stats[i.statut] ?? 0) + 1;
    }

    return InterventionState(stats: stats);
  }

  Future<void> reload() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final interventions = await interventionService.getAllRemote();

      final stats = <String, int>{};

      for (final i in interventions) {
        stats[i.statut] = (stats[i.statut] ?? 0) + 1;
      }

      return InterventionState(stats: stats);
    });
  }
}

final interventionStateNotifierProvider =
    AsyncNotifierProvider<InterventionNotifier, InterventionState>(
      InterventionNotifier.new,
    );
