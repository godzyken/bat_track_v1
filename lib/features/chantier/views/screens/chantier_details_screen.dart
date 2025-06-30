import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ChantierDetailScreen extends StatelessWidget {
  final Chantier chantier;

  const ChantierDetailScreen({super.key, required this.chantier});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(chantier.nom)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos générales
            Card(
              child: ListTile(
                title: Text(
                  chantier.nom,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Adresse : ${chantier.adresse}'),
                    Text('Client ID : ${chantier.clientId}'),
                    Text('Début : ${dateFormat.format(chantier.dateDebut)}'),
                    if (chantier.dateFin != null)
                      Text('Fin : ${dateFormat.format(chantier.dateFin!)}'),
                    if (chantier.etat != null) Text('État : ${chantier.etat}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Galerie photo
            if (chantier.photos.isNotEmpty) ...[
              Text(
                'Photos du chantier',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chantier.photos.length,
                  itemBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            chantier.photos[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Étapes du chantier
            if (chantier.etapes.isNotEmpty) ...[
              Text('Étapes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...chantier.etapes.map(
                (e) => Card(
                  child: ListTile(
                    leading: Icon(
                      e.terminee
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: e.terminee ? Colors.green : Colors.orange,
                    ),
                    title: Text(e.titre),
                    subtitle: Text(e.description),
                    trailing:
                        e.dateFin != null
                            ? Text(dateFormat.format(e.dateFin!))
                            : const Text('En cours'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Budget
            if (chantier.budgetPrevu! > 0) ...[
              Text('Budget', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prévu : ${chantier.budgetPrevu?.toStringAsFixed(2)} €',
                      ),
                      if (chantier.budgetReel != null) ...[
                        Text(
                          'Réel : ${chantier.budgetReel!.toStringAsFixed(2)} €',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (chantier.budgetReel! / chantier.budgetPrevu!)
                              .clamp(0.0, 2.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            chantier.budgetReel! > chantier.budgetPrevu!
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
