import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/models/private/technicien.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class TechnicienDetailScreen extends ConsumerWidget {
  final String technicienId;

  const TechnicienDetailScreen({super.key, required this.technicienId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicienAsync = ref.watch(watchTechnicienProvider(technicienId));

    final chantierAsync = ref.watch(allChantiersStreamProvider);
    final etapesAsync = ref.watch(allEtapesStreamProvider);

    return technicienAsync.when(
      data: (technicien) {
        if (technicien == null) {
          return const Center(child: Text('Technicien non trouvé'));
        }

        final chantiers = chantierAsync.value ?? [];
        final etapes = etapesAsync.value ?? [];

        final chantiersAffectes = chantiers
            .where(
              (chantier) => technicien.chantiersAffectees.contains(chantier.id),
            )
            .toList();

        final etapesAffectees = etapes
            .where((etape) => technicien.etapesAffectees.contains(etape.id))
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text('Détail de ${technicien.nom}')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _buildInfoSection(technicien),
                const SizedBox(height: 16),
                chantierAsync.isLoading
                    ? const LinearProgressIndicator()
                    : _buildAffectations(
                        'Chantiers affectés',
                        chantiersAffectes,
                      ),
                const SizedBox(height: 16),
                etapesAsync.isLoading
                    ? const LinearProgressIndicator()
                    : _buildAffectations('Étapes affectées', etapesAffectees),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Erreur Technicien: $err'))),
    );
  }

  Widget _buildInfoSection(Technicien tech) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📧 Email : ${tech.email}'),
        Text('📍 Localisation : ${tech.localisation ?? 'Non renseignée'}'),
        Text('💼 Spécialité : ${tech.specialite}'),
        Text('💰 Taux horaire : ${tech.tauxHoraire} €/h'),
        Text('🔧 Compétences : ${tech.competences.join(', ')}'),
        Text('🟢 Disponible : ${tech.disponible ? 'Oui' : 'Non'}'),
      ],
    );
  }

  Widget _buildAffectations(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return Text('$title : Aucune');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map(
          (e) => ListTile(
            title: e is ChantierEtape ? Text(e.titre) : const Text('Sans nom'),
            subtitle: e is ChantierEtape ? Text(e.description) : null,
          ),
        ),
      ],
    );
  }
}
