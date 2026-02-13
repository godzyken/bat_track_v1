import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final Projet projet;
  final AppUser currentUser;

  const ProjectDetailScreen({
    super.key,
    required this.projet,
    required this.currentUser,
  });

  Widget _buildStatusChip(String label, bool isValid, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isValid ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isValid ? color : Colors.grey[300],
      avatar: Icon(
        isValid ? Icons.check_circle : Icons.cancel,
        color: isValid ? Colors.white : Colors.black26,
        size: 18,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = projet.canEdit(currentUser);
    final canValidate = projet.canMerge(currentUser);

    return Scaffold(
      appBar: AppBar(
        title: Text(projet.nom),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier le projet',
              onPressed: () {
                // TODO: ouvrir l'édition
              },
            ),
          if (canValidate)
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              tooltip: 'Valider et synchroniser',
              onPressed: () {
                // TODO: validation / merge cloud
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              projet.nom,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              projet.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 32),

            // Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DateInfo(label: 'Début', date: projet.dateDebut),
                _DateInfo(label: 'Fin', date: projet.dateFin),
                _DateInfo(label: 'Deadline', date: projet.deadLine),
              ],
            ),
            const SizedBox(height: 24),

            // Validation statuses
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatusChip('Client', projet.clientValide, Colors.green),
                _buildStatusChip(
                  'Chef de projet',
                  projet.chefDeProjetValide,
                  Colors.blue,
                ),
                _buildStatusChip(
                  'Techniciens',
                  projet.techniciensValides,
                  Colors.orange,
                ),
                _buildStatusChip(
                  'Super utilisateur',
                  projet.superUtilisateurValide,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Membres
            Text(
              'Membres assignés',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (projet.members.isEmpty)
              Text(
                'Aucun membre assigné',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              ...projet.members.map(
                (uid) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(uid), // Remplacer par nom réel si possible
                  // TODO: afficher plus d'infos utilisateur ici si dispo
                ),
              ),

            const SizedBox(height: 40),

            if (canEdit)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier ce projet'),
                  onPressed: () {
                    // TODO: ouvrir édition complète
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime? date;

  const _DateInfo({required this.label, this.date});

  @override
  Widget build(BuildContext context) {
    final formattedDate = date == null ? '-' : DateFormat.yMd().format(date!);
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(formattedDate, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
