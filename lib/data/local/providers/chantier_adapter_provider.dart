import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/model_registry.dart';
import '../../core/unified_repository.dart';
import '../models/adapters/json_adapter.dart';
import '../models/chantiers/chantier.dart';

final chantierAdapterProvider = Provider<ChantierAdapter>((ref) {
  return ChantierAdapter();
});

final chantierRepoProvider = Provider<UnifiedRepository<Chantier>>((ref) {
  final config = ModelRegistry.getRepoConfig<Chantier>()!;
  return UnifiedRepository<Chantier>(config, ref);
});
