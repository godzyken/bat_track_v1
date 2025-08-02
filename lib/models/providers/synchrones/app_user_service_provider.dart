import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/utilisateurs/app_user.dart';
import '../../services/firestore_entity_service.dart';
import '../../services/logged_entity_service.dart';

final appUserServiceProvider = Provider<LoggedEntityService<AppUser>>((ref) {
  final delegate = FirestoreEntityService<AppUser>(
    collectionPath: 'users',
    fromJson: (json) => AppUser.fromJson(json),
  );
  return LoggedEntityService(delegate, ref);
});
