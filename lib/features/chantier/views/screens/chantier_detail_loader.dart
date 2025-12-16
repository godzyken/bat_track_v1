import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
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
      loading: () => const LoadingApp(),
      error:
          (e, _) => ErrorApp(
            message: "Erreur lors du chargement des détails du chantier : $e",
          ),
      data: (chantier) {
        if (chantier == null) {
          return const Scaffold(
            body: Center(child: Text('Chantier introuvable')),
          );
        }
        return ChantierDetailScreen(chantierId: chantier.id);
      },
    );
  }
}
