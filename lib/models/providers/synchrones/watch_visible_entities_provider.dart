import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/base/has_acces_control.dart';
import '../../../data/local/models/utilisateurs/app_user.dart';
import '../../../features/auth/data/providers/current_user_provider.dart';
import '../../data/json_model.dart';
import '../adapter/wath_entities_args.dart';

AutoDisposeProvider<Stream<List<T>>>
watchVisibleEntitiesProvider<T extends JsonModel>(WatchEntitiesArgs<T> args) {
  return Provider.autoDispose<Stream<List<T>>>((ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Stream.empty();

    final service = ref.watch(args.serviceProvider);
    return service.watchByChantier(args.chantierId).map((entities) {
      final u = AppUser(
        uid: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        createdAt: user.createdAt,
      );
      return _filterByUserRole<T>(entities, u);
    });
  });
}

List<T> _filterByUserRole<T>(List<T> entities, AppUser user) {
  if (user.role == 'admin') return entities;

  return entities
      .whereType<HasAccessControl>()
      .where((e) => e.canAccess(user))
      .cast<T>()
      .toList();
}
