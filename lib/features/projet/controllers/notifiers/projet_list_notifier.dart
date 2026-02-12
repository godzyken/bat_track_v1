import 'package:bat_track_v1/data/local/models/projets/projet_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../auth/data/providers/current_user_provider.dart';

class ProjetListNotifier extends StateNotifier<AsyncValue<List<Projet>>> {
  final Ref ref;
  ProjetListNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final firestore = ref.read(firestoreProvider);
    firestore.collection('projects').snapshots().listen((snapshot) {
      final projets = snapshot.docs
          .map((doc) => Projet.fromJson(doc.data()))
          .toList();
      state = AsyncValue.data(projets);
    });
  }

  /// Crée un nouveau projet
  Future<void> addProject(Projet projet) async {
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection('projects')
          .doc(projet.id)
          .set(projet.toJson());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Met à jour un projet
  Future<void> updateProject(Projet projet) async {
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection('projects')
          .doc(projet.id)
          .update(projet.toJson());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Supprime un projet
  Future<void> deleteProject(String id) async {
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('projects').doc(id).delete();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Validation par le client
  Future<void> validateByClient(String projectId) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;
    final projet = state.value?.firstWhere((p) => p.id == projectId);
    if (projet == null) return;

    final updated = projet.validateByClient(currentUser.uid);
    await updateProject(updated);
  }

  /// Validation par admin / chef de projet
  Future<void> validateByAdminOrChef(String projectId) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;
    final projet = state.value?.firstWhere((p) => p.id == projectId);
    if (projet == null) return;

    final updated = projet.validateByAdminOrChef(currentUser);
    await updateProject(updated);
  }

  /// Assignation technicien
  Future<void> assignTechnician(String projectId, AppUser technician) async {
    final projet = state.value?.firstWhere((p) => p.id == projectId);
    if (projet == null) return;

    final updated = projet.assignTechnician(technician);
    await updateProject(updated);
  }
}

final projetListProvider =
    StateNotifierProvider<ProjetListNotifier, AsyncValue<List<Projet>>>(
      (ref) => ProjetListNotifier(ref),
    );
