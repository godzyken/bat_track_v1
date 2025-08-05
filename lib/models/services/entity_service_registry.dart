import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/json_model.dart';
import 'firestore_entity_service.dart';
import 'logged_entity_service.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

Provider<LoggedEntityService<T>> buildEntityServiceProvider<
  T extends JsonModel
>({required String collectionPath, required FromJson<T> fromJson}) {
  return Provider<LoggedEntityService<T>>((ref) {
    final delegate = FirestoreEntityService<T>(
      collectionPath: collectionPath,
      fromJson: fromJson,
    );
    return LoggedEntityService(delegate, ref.read);
  });
}
