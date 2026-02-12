import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

class RechercheTechnicienScreen extends ConsumerStatefulWidget {
  const RechercheTechnicienScreen({super.key});

  @override
  ConsumerState<RechercheTechnicienScreen> createState() =>
      _RechercheTechnicienScreenState();
}

class _RechercheTechnicienScreenState
    extends ConsumerState<RechercheTechnicienScreen> {
  String? _specialiteSelectionnee;
  String? _regionSelectionnee;

  @override
  Widget build(BuildContext context) {
    final params = TechnicienSearchParams(
      specialite: _specialiteSelectionnee,
      region: _regionSelectionnee,
      disponibleUniquement: true,
      minRating: 3.5,
    );

    final techniciensAsync = ref.watch(techniciensSearchProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Trouver un technicien')),
      body: Column(
        children: [
          // Filtres
          _buildFiltres(),

          // Liste des résultats
          Expanded(
            child: techniciensAsync.when(
              data: (techniciens) {
                if (techniciens.isEmpty) {
                  return const Center(
                    child: Text('Aucun technicien disponible'),
                  );
                }

                return ListView.builder(
                  itemCount: techniciens.length,
                  itemBuilder: (context, index) {
                    final tech = techniciens[index];
                    return _TechnicienCard(technicien: tech);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltres() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _specialiteSelectionnee,
            decoration: const InputDecoration(labelText: 'Spécialité'),
            items: [
              'Plomberie',
              'Électricité',
              'Chauffage',
              'Climatisation',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (value) {
              setState(() => _specialiteSelectionnee = value);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _regionSelectionnee,
            decoration: const InputDecoration(labelText: 'Région'),
            items: [
              'Béziers',
              'Montpellier',
              'Narbonne',
              'Perpignan',
            ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (value) {
              setState(() => _regionSelectionnee = value);
            },
          ),
        ],
      ),
    );
  }
}

class _TechnicienCard extends StatelessWidget {
  final Technicien technicien;

  const _TechnicienCard({required this.technicien});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(technicien.nom.substring(0, 1))),
        title: Text(technicien.nom),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(technicien.specialite),
            Text('${technicien.tauxHoraire}€/h'),
            if (technicien.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(' ${technicien.rating!.toStringAsFixed(1)}'),
                ],
              ),
          ],
        ),
        trailing: technicien.disponible
            ? const Chip(
                label: Text('Disponible'),
                backgroundColor: Colors.green,
              )
            : null,
        onTap: () {
          // Navigation vers détail technicien
        },
      ),
    );
  }
}
