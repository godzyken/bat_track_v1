import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/chantier/views/widgets/chantier_extensions_widgets.dart';
import 'package:bat_track_v1/models/data/state_wrapper/wrappers.dart';
import 'package:bat_track_v1/models/notifiers/sync_entity_notifier.dart';
import 'package:bat_track_v1/models/providers/synchrones/generic_entity_provider_factory.dart';
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
  final bool isClient;
  final bool isTechnicien;
  final String? userId;

  const ChantierDetailScreen({
    super.key,
    required this.chantier,
    this.isClient = false,
    this.isTechnicien = false,
    this.userId,
  });

  bool get chantierModifiable {
    final now = DateTime.now();
    return chantier.dateFin!.isAfter(now) &&
        ['à faire', 'en cours'].contains(chantier.etat?.toLowerCase());
  }

  bool canModifyEtape(ChantierEtape etape) {
    final now = DateTime.now();
    if (isClient) return chantierModifiable;
    if (isTechnicien) {
      return etape.techniciens!.contains(userId) &&
          (etape.dateFin.isAfter(now));
    }
    return true; // admin ou autre
  }

  bool get chantierEstTermine {
    return chantier.etapes.every((e) => e.terminee) &&
        chantier.clientValide &&
        chantier.chefDeProjetValide &&
        chantier.techniciensValides &&
        chantier.superUtilisateurValide;
  }

  void _updateEtape(
    ChantierEtape updatedEtape,
    SyncEntityNotifier<Chantier> notifier,
  ) {
    final updatedList =
        chantier.etapes
            .map((e) => e.id == updatedEtape.id ? updatedEtape : e)
            .toList();
    notifier.update(chantier.copyWith(etapes: updatedList));
  }

  void _deleteEtape(String id, SyncEntityNotifier<Chantier> notifier) {
    final updatedList = chantier.etapes.where((e) => e.id != id).toList();
    notifier.update(chantier.copyWith(etapes: updatedList));
  }

  void _reorderEtapes(
    List<ChantierEtape> reordered,
    SyncEntityNotifier<Chantier> notifier,
  ) {
    notifier.update(chantier.copyWith(etapes: reordered));
  }

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

  Widget buildSection(String title, Widget child) {
    return Column(
      children: [
        SectionCard(title: title, child: child),
        const SizedBox(height: 16),
      ],
    );
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
                      buildSection(
                        "Connexion Dolibarr",
                        DolibarrSection(onSync: () => notifier.syncNow()),
                      ),
                      const SizedBox(height: 16),

                      // Infos générales
                      buildSection(
                        "Informations générales",
                        ChantierCardInfo(
                          chantier: state.data,
                          dateFormat: dateFormat,
                          onChanged: notifier.update,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      buildSection(
                        "Description",
                        ChantierDescription(
                          chantier: chantier,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Documents
                      buildSection(
                        "Documents",
                        ChantierListDocuments(chantier: chantier),
                      ),
                      const SizedBox(height: 16),

                      // Budget
                      buildSection(
                        "Budget",
                        BudgetDetailSansTech(details: totalBudget),
                      ),
                      const SizedBox(height: 16),

                      // Étapes avec timeline interactive
                      buildSection(
                        "Étapes du chantier",
                        chantierEstTermine
                            ? ChantiersEtapeKanbanReadOnly(
                              etapes: chantier.etapes,
                            )
                            : ChantiersEtapeKanbanInteractive(
                              etapes: chantier.etapes,
                              canEditEtape: canModifyEtape,
                              onReorder:
                                  (reordered) =>
                                      _reorderEtapes(reordered, notifier),
                              onDelete: (id) => _deleteEtape(id, notifier),
                              onUpdate:
                                  (updatedEtape) =>
                                      _updateEtape(updatedEtape, notifier),
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
