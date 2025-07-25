import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';
import 'chantier_details_screen.dart';

class ChantierDetailLoader extends ConsumerWidget {
  final String chantierId;
  final Chantier? initialData;

  const ChantierDetailLoader({
    super.key,
    required this.chantierId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chantierAsync =
        initialData != null
            ? AsyncValue.data(initialData!)
            : ref.watch(chantierFutureProvider(chantierId));

    return chantierAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur : $e'))),
      data: (chantier) {
        if (chantier == null) {
          return const Scaffold(
            body: Center(child: Text('Chantier introuvable')),
          );
        }
        return ChantierDetailScreen(chantier: chantier);
      },
    );
  }
}
