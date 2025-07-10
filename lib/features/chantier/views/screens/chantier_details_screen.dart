import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/chantier/views/widgets/budget_detail_sans_tech.dart';
import 'package:bat_track_v1/features/chantier/views/widgets/chantier_etape_time_line_interactive.dart';
import 'package:bat_track_v1/features/chantier/views/widgets/chantier_list_documents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../dolibarr/views/widgets/sync_statu_bar.dart';
import '../../controllers/providers/chantier_sync_provider.dart';
import '../widgets/chantier_card_info.dart';
import '../widgets/chantier_discription.dart';
import '../widgets/section_card.dart';

class ChantierDetailScreen extends ConsumerWidget {
  final Chantier chantier;

  const ChantierDetailScreen({super.key, required this.chantier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = context.responsiveInfo(ref);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final state = ref.watch(chantierSyncProvider(chantier));
    final notifier = ref.read(chantierSyncProvider(chantier).notifier);

    final totalBudget = computeTotalBudget(chantier.etapes);

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
                        child: ChantiersEtapeTimelineInteractive(
                          etapes: chantier.etapes,
                          onReorder: (reordered) {
                            notifier.update(
                              chantier.copyWith(etapes: reordered),
                            );
                          },
                          onDelete: (id) {
                            notifier.update(
                              chantier.copyWith(
                                etapes:
                                    chantier.etapes
                                        .where((e) => e.id != id)
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
