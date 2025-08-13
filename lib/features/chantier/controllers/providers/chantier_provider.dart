import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantiers/chantier.dart';
import 'chantier_repository_provider.dart';

final chantiersProvider =
    FutureProvider.family<List<Chantier>, (String uid, String role)>((
      ref,
      tuple,
    ) {
      final repo = ref.read(chantierRepositoryProvider);
      final (uid, role) = tuple;

      switch (role) {
        case 'admin':
          return repo.getAll(limit: 50);
        case 'tech':
          return repo.getForTechnicien(uid);
        case 'client':
          return repo.getForClient(uid);
        default:
          return Future.value([]);
      }
    });
