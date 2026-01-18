import 'package:bat_track_v1/data/remote/providers/chantier_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repository/chantier_repository.dart';

final chantierRepositoryProvider = Provider<ChantierRepository>((ref) {
  final service = ref.watch(chantierServiceProvider);
  return ChantierRepository(service);
});
