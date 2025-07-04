import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class ChantiersEtapeListPreview extends ConsumerWidget {
  final List<ChantierEtape>? etapes;
  final void Function(int index) onTap;

  const ChantiersEtapeListPreview({
    required this.etapes,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (etapes == null || etapes!.isEmpty) {
      return const Text("Aucune étape enregistrée.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étapes du chantier',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...etapes!.asMap().entries.map((entry) {
          final index = entry.key;
          final etape = entry.value;

          return Card(
            child: ListTile(
              leading: Icon(
                etape.terminee == true
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: etape.terminee == true ? Colors.green : Colors.grey,
              ),
              title: Text(
                etape.titre.isNotEmpty == true
                    ? etape.titre
                    : 'Étape ${index + 1}',
              ),
              subtitle: Text(etape.description),
              trailing: const Icon(Icons.edit),
              onTap: () {
                final chantier = ref.watch(chantierProvider(etape.chantierId!));
                context.goNamed(
                  'chantier-etape-detail',
                  pathParameters: {
                    'id': etape.chantierId!,
                    'etapeId': etape.id!,
                  },
                  extra: {'chantier': chantier, 'etape': etape},
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
