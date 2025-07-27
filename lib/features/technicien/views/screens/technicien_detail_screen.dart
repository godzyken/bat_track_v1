import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class TechnicienDetailScreen extends ConsumerWidget {
  final String technicienId;

  const TechnicienDetailScreen({super.key, required this.technicienId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final technicien = ref.watch(technicienNotifierProvider(technicienId));

    if (technicien == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final chantiers = ref.watch(allChantiersProvider);
    final etapes = ref.watch(allEtapesProvider);

    final chantiersAffectes =
        chantiers
            .where(
              (chantier) => technicien.chantiersAffectees.contains(chantier.id),
            )
            .toList();

    final etapesAffectees =
        etapes
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
            _buildAffectations('Chantiers affectés', chantiersAffectes),
            const SizedBox(height: 16),
            _buildAffectations('Étapes affectées', etapesAffectees),
          ],
        ),
      ),
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
            title: Text(e.titre ?? e.nom ?? 'Sans nom'),
            subtitle: e is ChantierEtape ? Text(e.description) : null,
          ),
        ),
      ],
    );
  }
}
