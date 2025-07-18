import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';

class InterventionState {
  final bool isLoading;
  final Map<String, int>? stats;
  final String? error;

  InterventionState({this.isLoading = false, this.stats, this.error});

  InterventionState copyWith({
    bool? isLoading,
    Map<String, int>? stats,
    String? error,
  }) {
    return InterventionState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}

class InterventionStateNotifier extends StateNotifier<InterventionState> {
  final EntityServices<Intervention> interventionService;

  InterventionStateNotifier(this.interventionService)
    : super(InterventionState()) {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final interventions = await interventionService.getAll();

      final Map<String, int> stats = {
        'Terminée': 0,
        'En cours': 0,
        'Annulée': 0,
      };

      for (final i in interventions) {
        stats[i.statut] = (stats[i.statut] ?? 0) + 1;
      }

      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final interventionStateNotifierProvider =
    StateNotifierProvider<InterventionStateNotifier, InterventionState>(
      (ref) => InterventionStateNotifier(interventionService),
    );
