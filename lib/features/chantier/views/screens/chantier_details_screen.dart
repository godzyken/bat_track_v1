import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/chantier/views/widgets/chantier_extensions_widgets.dart';
import 'package:bat_track_v1/models/data/state_wrapper/wrappers.dart';
import 'package:bat_track_v1/models/notifiers/sync_entity_notifier.dart';
import 'package:bat_track_v1/models/providers/synchrones/sync_entity_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../dolibarr/views/widgets/dolibarr_section.dart';
import '../../../dolibarr/views/widgets/sync_statu_bar.dart';
import '../../controllers/providers/chantier_sync_provider.dart';

class ChantierDetailScreen extends ConsumerWidget {
  final Chantier chantier;

  const ChantierDetailScreen({super.key, required this.chantier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final state = ref.watch(ref.syncEntity<Chantier>(chantier.id));
    final notifier = ref.read(chantierSyncProvider(chantier).notifier);

    final totalBudget = computeTotalBudget(chantier.etapes);

    return switch (state) {
      SyncedState<Chantier>(data: final chantier) => buildPopScope(
        notifier,
        chantier,
        state,
        dateFormat,
        totalBudget,
        context,
      ),
    };
  }

  PopScope<Object> buildPopScope(
    SyncEntityNotifier<Chantier> notifier,
    Chantier chantier,
    SyncedState<Chantier> state,
    DateFormat dateFormat,
    Map<String, double> totalBudget,
    BuildContext context,
  ) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await notifier.syncNow();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Chantier : ${chantier.nom}')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SyncStatusBar(
                          isSyncing: state.isSyncing,
                          hasError: state.hasError,
                          lastSynced: state.lastSynced,
                          onForceSync: notifier.syncNow,
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "⚠️ Une erreur est survenue lors de la dernière synchronisation.",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),

                      // Infos Dolibarrr
                      SectionCard(
                        title: "Connexion Dolibarr",
                        child: DolibarrSection(
                          onSync: () => notifier.syncNow(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Infos générales
                      SectionCard(
                        title: "Informations générales",
                        child: ChantierCardInfo(
                          chantier: state.data,
                          dateFormat: dateFormat,
                          onChanged: notifier.update,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      SectionCard(
                        title: "Description",
                        child: ChantierDescription(
                          chantier: chantier,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Documents
                      SectionCard(
                        title: "Documents",
                        child: ChantierListDocuments(chantier: chantier),
                      ),
                      const SizedBox(height: 16),

                      // Budget
                      SectionCard(
                        title: "Budget",
                        child: BudgetDetailSansTech(details: totalBudget),
                      ),
                      const SizedBox(height: 16),

                      // Étapes avec timeline interactive
                      SectionCard(
                        title: "Étapes du chantier",
                        child: ChantiersEtapeKanbanInteractive(
                          etapes: chantier.etapes,
                          onReorder: (reordered) {
                            notifier.update(
                              chantier.copyWith(etapes: reordered),
                            );
                          },
                          onDelete: (id) {
                            notifier.update(
                              chantier.copyWith(
                                etapes: chantier.etapes
                                    .where((e) => e.id != id.toString())
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'syncNow',
              onPressed: notifier.syncNow,
              label: const Text("Forcer la synchro"),
              icon: const Icon(Icons.sync),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              heroTag: 'addEtape',
              onPressed: () {
                context.goNamed(
                  'chantier-etape-detail',
                  pathParameters: {'id': chantier.id},
                );
              },
              label: const Text("Ajouter une étape"),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  /// Calcule le budget total toutes catégories confondues
  Map<String, double> computeTotalBudget(List<ChantierEtape> etapes) {
    return etapes
        .map<Map<String, double>>(
          (e) => (e.budget ?? {}) as Map<String, double>,
        )
        .fold<Map<String, double>>({}, (acc, map) {
          map.forEach((key, value) {
            acc.update(key, (v) => v + value, ifAbsent: () => value);
          });
          return acc;
        });
  }
}
