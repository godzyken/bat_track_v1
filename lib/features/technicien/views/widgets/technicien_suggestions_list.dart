import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../controllers/providers/technicien_providers.dart';

class TechnicienSuggestionsList extends ConsumerWidget {
  final Projet projet;

  const TechnicienSuggestionsList({super.key, required this.projet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(technicienSuggestionsProvider);

    return suggestions.when(
      data:
          (techs) =>
              techs.isEmpty
                  ? const Text("Aucun technicien correspondant trouvé.")
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: techs.length,
                    itemBuilder: (context, i) {
                      final t = techs[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(t.nom),
                        subtitle: Text(
                          "${t.specialite} • ${t.localisation ?? 'Non renseignée'}",
                        ),
                        trailing: Text(
                          "${t.tauxHoraire.toStringAsFixed(2)} €/h",
                        ),
                        onTap: () {
                          // 👉 Ici tu pourrais auto-assigner ce technicien au projet
                        },
                      );
                    },
                  ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Erreur: $e"),
    );
  }
}
