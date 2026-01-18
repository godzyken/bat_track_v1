import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ChantierCardInfo extends ConsumerWidget {
  const ChantierCardInfo({
    super.key,
    required this.chantier,
    required this.dateFormat,
    required this.onChanged,
  });

  final Chantier chantier;
  final DateFormat dateFormat;
  final ValueChanged<Chantier> onChanged;

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    ValueChanged<DateTime> onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> etatOptions = [
      'À venir',
      'En cours',
      'Terminé',
      'Annulé',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: chantier.nom,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Nom du chantier',
              ),
              onChanged: (value) => onChanged(chantier.copyWith(nom: value)),
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.name],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: chantier.adresse,
              decoration: const InputDecoration(labelText: 'Adresse'),
              onChanged: (value) =>
                  onChanged(chantier.copyWith(adresse: value)),
              keyboardType: TextInputType.streetAddress,
              autofillHints: const [AutofillHints.fullStreetAddress],
            ),
            const SizedBox(height: 12),

            TextFormField(
              initialValue: chantier.clientId,
              decoration: const InputDecoration(labelText: 'Client ID'),
              onChanged: (value) =>
                  onChanged(chantier.copyWith(clientId: value)),
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Date de début',
              button: true,
              child: GestureDetector(
                onTap: () => _selectDate(
                  context,
                  chantier.dateDebut,
                  (newDate) => onChanged(chantier.copyWith(dateDebut: newDate)),
                ),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date de début'),
                  child: Text(dateFormat.format(chantier.dateDebut)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Date de fin',
              button: true,
              child: GestureDetector(
                onTap: () => _selectDate(
                  context,
                  chantier.dateFin ?? chantier.dateDebut,
                  (newDate) => onChanged(chantier.copyWith(dateFin: newDate)),
                ),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date de fin'),
                  child: Text(
                    chantier.dateFin != null
                        ? dateFormat.format(chantier.dateFin!)
                        : 'Non définie',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value:
                  chantier.etat != null && etatOptions.contains(chantier.etat)
                  ? chantier.etat
                  : null,
              decoration: const InputDecoration(labelText: 'État'),
              items: etatOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(chantier.copyWith(etat: value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
