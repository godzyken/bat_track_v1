import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../chantier/controllers/providers/chantier_sync_provider.dart';

final editingProjetProvider = StateProvider<Projet?>((ref) => null);

final techniciensStreamProvider = StreamProvider<List<Technicien>>((ref) {
  final service = ref.watch(techSyncServiceProvider);
  return service.watchAllCombined();
});

final techniciensFutureProvider = FutureProvider<List<Technicien>>((ref) async {
  final service = ref.watch(techSyncServiceProvider);
  return await service.getAll();
});

final technicienSuggestionsProvider = FutureProvider<List<Technicien>>((
  ref,
) async {
  final projet = ref.watch(editingProjetProvider);

  if (projet == null) return [];

  final firestore = ref.watch(firestoreProvider);

  final snapshot = await firestore.collection('techniciens').get();

  final allTechs = snapshot.docs
      .map((doc) => Technicien.fromJson(doc.data()))
      .toList();

  // 🔹 Filtrage par spécialité
  var filtered = allTechs.where(
    (t) =>
        t.specialite.toLowerCase() == (projet.specialite ?? '').toLowerCase(),
  );

  // 🔹 Filtrage par disponibilité
  filtered = filtered.where((t) => t.disponible);

  // 🔹 Filtrage par localisation (simple contient)
  if (projet.localisation != null && projet.localisation!.isNotEmpty) {
    final loc = projet.localisation!.toLowerCase();
    filtered = filtered.where(
      (t) => (t.localisation ?? '').toLowerCase().contains(loc),
    );
  }

  return filtered.toList();
});

final technicienFilterProvider = StateProvider<TechFilter>((ref) {
  return TechFilter();
});

class TechFilter {
  final String? specialite;
  final String? localisation;
  final bool? disponible;
  final String? searchQuery;

  TechFilter({
    this.specialite,
    this.localisation,
    this.disponible,
    this.searchQuery,
  });

  TechFilter copyWith({
    String? specialite,
    String? localisation,
    bool? disponible,
    String? searchQuery,
  }) {
    return TechFilter(
      specialite: specialite ?? this.specialite,
      localisation: localisation ?? this.localisation,
      disponible: disponible ?? this.disponible,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool apply(Technicien t) {
    if (specialite != null && t.specialite != specialite) return false;
    if (localisation != null && t.localisation != localisation) return false;
    if (disponible != null && t.disponible != disponible) return false;
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final q = searchQuery!.toLowerCase();
      if (!t.nom.toLowerCase().contains(q) &&
          !t.competences.any((c) => c.toLowerCase().contains(q))) {
        return false;
      }
    }
    return true;
  }
}
