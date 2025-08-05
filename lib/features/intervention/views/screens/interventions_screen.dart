import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantiers/intervention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class InterventionsScreen extends ConsumerWidget {
  final String chantierId;

  const InterventionsScreen({super.key, required this.chantierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interventionService = ref.watch(interventionServiceProvider);
    return StreamBuilder<List<Intervention>>(
      stream: interventionService.watchByChantier(chantierId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final interventions = snapshot.data!;
        return ListView(
          children:
              interventions
                  .map((i) => ListTile(title: Text(i.titre ?? '')))
                  .toList(),
        );
      },
    );
  }
}
