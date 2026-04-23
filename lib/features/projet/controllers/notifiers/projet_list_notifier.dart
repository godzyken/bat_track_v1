import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../auth/data/providers/current_user_provider.dart';

class ProjetListNotifier extends AsyncNotifier<List<Projet>> {
  @override
  Future<List<Projet>> build() async {
    final firestore = ref.read(firestoreProvider);

    // 🔥 Stream Firestore → state automatique
    ref.listen(
      StreamProvider((ref) {
        return firestore.collection('projects').snapshots();
      }),
      (_, next) {
        next.whenData((snapshot) {
          final projets = snapshot.docs
              .map((doc) => Projet.fromJson(doc.data()))
              .toList();

          state = AsyncData(projets);
        });
      },
    );

    // état initial
    final snapshot = await firestore.collection('projects').get();

    return snapshot.docs.map((doc) => Projet.fromJson(doc.data())).toList();
  }

  // ------------------------------------------------------------------
  // CRUD
  // ------------------------------------------------------------------

  Future<void> addProject(Projet projet) async {
    final firestore = ref.read(firestoreProvider);

    state = await AsyncValue.guard(() async {
      await firestore
          .collection('projects')
          .doc(projet.id)
          .set(projet.toJson());

      return state.value ?? [];
    });
  }

  Future<void> updateProject(Projet projet) async {
    final firestore = ref.read(firestoreProvider);

    state = await AsyncValue.guard(() async {
      await firestore
          .collection('projects')
          .doc(projet.id)
          .update(projet.toJson());

      return state.value ?? [];
    });
  }

  Future<void> deleteProject(String id) async {
    final firestore = ref.read(firestoreProvider);

    state = await AsyncValue.guard(() async {
      await firestore.collection('projects').doc(id).delete();
      return state.value ?? [];
    });
  }

  // ------------------------------------------------------------------
  // LOGIQUE MÉTIER
  // ------------------------------------------------------------------

  Future<void> validateByClient(String projectId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final projet = state.value?.firstWhere((p) => p.id == projectId);
    if (projet == null) return;

    await updateProject(projet.validateByClient(user.uid));
  }

  Future<void> validateByAdminOrChef(String projectId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final projet = state.value?.firstWhere((p) => p.id == projectId);
    if (projet == null) return;

    await updateProject(projet.validateByAdminOrChef(user));
  }

  Future<void> assignTechnician(String projectId, AppUser tech) async {
    final projet = state.value?.firstWhere((p) => p.id == projectId);
    if (projet == null) return;

    await updateProject(projet.assignTechnician(tech));
  }
}

final projetListProvider =
    AsyncNotifierProvider<ProjetListNotifier, List<Projet>>(
      ProjetListNotifier.new,
    );
