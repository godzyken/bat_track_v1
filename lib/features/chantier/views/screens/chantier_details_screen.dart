import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/chantier/views/widgets/chantier_extensions_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';
import '../../../dolibarr/views/widgets/dolibarr_section.dart';
import '../../../dolibarr/views/widgets/sync_statu_bar.dart';
import '../../controllers/notifiers/chantier_notifier.dart';

class ChantierDetailScreen extends ConsumerWidget {
  final String chantierId;
  final bool isClient;
  final bool isTechnicien;
  final String? userId;

  const ChantierDetailScreen({
    super.key,
    required this.chantierId,
    this.isClient = false,
    this.isTechnicien = false,
    this.userId,
  });

  bool chantierModifiable(Chantier chantier) {
    final now = DateTime.now();
    return chantier.dateFin!.isAfter(now) &&
        ['à faire', 'en cours'].contains(chantier.etat?.toLowerCase());
  }

  bool canModifyEtape(ChantierEtape etape, Chantier chantier) {
    final now = DateTime.now();
    if (isClient) return chantierModifiable(chantier);
    if (isTechnicien) {
      return etape.techniciens!.contains(userId) &&
          (etape.dateFin.isAfter(now));
    }
    return true; // admin ou autre
  }

  bool chantierEstTermine(Chantier chantier) {
    return chantier.etapes.every((e) => e.terminee) &&
        chantier.clientValide &&
        chantier.chefDeProjetValide &&
        chantier.techniciensValides &&
        chantier.superUtilisateurValide;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final dateFormat = DateFormat('dd/MM/yyyy');

    // ✅ NOUVEAU : Lecture du Notifier familial
    final chantierAsync = ref.watch(
      chantierAdvancedNotifierProvider(chantierId),
    );

    // ✅ NOUVEAU : Lecture du Notifier pour les actions
    // On lit le Notifier lui-même (pas la valeur) pour accéder aux méthodes
    final notifier = ref.read(
      chantierAdvancedNotifierProvider(chantierId).notifier,
    );

    return chantierAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
      data: (chantier) {
        if (chantier == null) {
          return const Center(child: Text('Chantier non trouvé.'));
        }

        final totalBudget = computeTotalBudget(chantier.etapes);

        // ✅ L'ancienne logique 'switch' est remplacée par 'chantierAsync.when'
        return buildPopScope(
          notifier, // Nouveau Notifier
          chantier,
          // L'état de synchro doit être lu séparément (voir point 2 ci-dessous)
          // Pour l'instant, on laisse des valeurs par défaut
          false, // isSyncing
          false, // hasError
          null, // lastSynced
          dateFormat,
          totalBudget,
          context,
        );
      },
    );
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
    ChantierNotifier notifier,
    Chantier chantier,
    bool isSyncing, // Simplifié
    bool hasError, // Simplifié
    DateTime? lastSynced,
    DateFormat dateFormat,
    Map<String, double> totalBudget,
    BuildContext context,
  ) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await notifier.recalculateFactureDraft();
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
                          isSyncing: isSyncing,
                          hasError: hasError,
                          lastSynced: lastSynced,
                          onForceSync: () => notifier.updateChantier(chantier),
                        ),
                      ),
                      if (hasError)
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
                        DolibarrSection(
                          onSync: () => notifier.updateChantier(chantier),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Infos générales
                      buildSection(
                        "Informations générales",
                        ChantierCardInfo(
                          chantier: chantier,
                          dateFormat: dateFormat,
                          onChanged: notifier.updateChantier,
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
                        chantierEstTermine(chantier)
                            ? ChantiersEtapeKanbanReadOnly(
                              etapes: chantier.etapes,
                            )
                            : ChantiersEtapeKanbanInteractive(
                              etapes: chantier.etapes,
                              canEditEtape:
                                  (etape) => canModifyEtape(etape, chantier),
                              onReorder: (reordered) {
                                notifier.updateChantier(
                                  chantier.copyWith(etapes: reordered),
                                );
                              },
                              onDelete: notifier.deleteEtape,
                              onUpdate: notifier.updateEtape,
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
              onPressed: () => notifier.updateChantier(chantier),
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
