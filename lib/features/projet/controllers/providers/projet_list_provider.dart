import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../auth/data/providers/auth_state_provider.dart';

final projectListProvider = StreamProvider<List<Projet>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('projects')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Projet.fromJson(doc.data())).toList(),
      );
});
