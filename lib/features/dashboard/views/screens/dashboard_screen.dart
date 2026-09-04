import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/notifiers/logged_notifier.dart';
import '../../../../models/views/screens/exeception_screens.dart';
import '../../../dolibarr/views/widgets/dolibarr_section.dart';
import '../../../intervention/controllers/providers/intervention_stats_provider.dart';
import '../../../intervention/views/widgets/intervention_chart.dart';
import '../../../../core/widgets/fiscal_integrity_indicator.dart';
import '../../controllers/providers/projection_provider.dart';
import '../../../../core/financial_engine/projection_engine.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? selectedProjectId;
  String? selectedChantierId;

  @override
  Widget build(BuildContext context) {
    final info = context.responsiveInfo(ref);
    final statsAsync = ref.watch(interventionStatsProvider);
    final loggerState = ref.watch(loggerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard intelligent'),
        actions: [
          const Center(child: FiscalIntegrityIndicator()),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(interventionStatsProvider);
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingApp(),
        error: (e, _) => ErrorApp(message: 'Erreur dashboard : $e'),
        data: (stats) {
          final projets = stats.keys.toList();

          final filteredChantiers = selectedProjectId != null
              ? stats[selectedProjectId!]!.keys.toList()
              : stats.values.expand((e) => e.keys).toSet().toList();

          final pieData = <String, int>{};
          final barData = <String, int>{};

          for (var projetId
              in (selectedProjectId != null ? [selectedProjectId!] : projets)) {
            final chantiers = stats[projetId]!;
            for (var chantierId
                in (selectedChantierId != null
                    ? [selectedChantierId!]
                    : chantiers.keys)) {
              final chantierStats = chantiers[chantierId]!;
              chantierStats.forEach((k, v) {
                pieData[k] = (pieData[k] ?? 0) + v;
                barData[k] = (barData[k] ?? 0) + v;
              });
            }
          }

          /// 📡 LOG ANALYTICS
          final logStats = loggerState.actionsCount;
          final logTargets = loggerState.targetUsage;

          /// ⚠️ Détection anomalies
          final tooManyDeletes = (logStats['delete'] ?? 0) > 5;

          final highActivity = loggerState.totalLogs > 50;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DolibarrSection(),
                const SizedBox(height: 16),

                /// 🚨 ALERTES INTELLIGENTES
                if (tooManyDeletes || highActivity)
                  Card(
                    color: Colors.red.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: const Text('Anomalie détectée'),
                      subtitle: Text(
                        tooManyDeletes
                            ? 'Trop de suppressions détectées'
                            : 'Activité très élevée',
                      ),
                    ),
                  ),

                /// 🎯 FILTRES PROJETS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous'),
                        selected: selectedProjectId == null,
                        onSelected: (_) {
                          setState(() {
                            selectedProjectId = null;
                            selectedChantierId = null;
                          });
                        },
                      ),
                      ...projets.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(p),
                            selected: selectedProjectId == p,
                            onSelected: (_) {
                              setState(() {
                                selectedProjectId = p;
                                selectedChantierId = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                /// 🎯 FILTRES CHANTIERS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous chantiers'),
                        selected: selectedChantierId == null,
                        onSelected: (_) {
                          setState(() {
                            selectedChantierId = null;
                          });
                        },
                      ),
                      ...filteredChantiers.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: selectedChantierId == c,
                            onSelected: (_) {
                              setState(() {
                                selectedChantierId = c;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 📊 CHARTS METIER
                if (info.screenSize == ScreenSize.tablet)
                  Row(
                    children: [
                      Expanded(child: AnimatedInterventionChart(data: pieData)),
                      const SizedBox(width: 16),
                      Expanded(child: AnimatedInterventionChart(data: barData)),
                    ],
                  )
                else
                  Column(
                    children: [
                      AnimatedInterventionChart(data: pieData),
                      const SizedBox(height: 16),
                      AnimatedInterventionChart(data: barData),
                    ],
                  ),

                const SizedBox(height: 24),

                /// 🏦 PROJECTIONS FINANCIÈRES (Convergence BTP 4.0)
                ref
                    .watch(cashflowProjectionProvider)
                    .when(
                      data: (proj) => _buildProjectionSection(proj),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Erreur projection : $e'),
                    ),

                const SizedBox(height: 24),

                /// 📡 ANALYTICS LOGS
                const Text(
                  'Activité système',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                AnimatedInterventionChart(data: logStats),

                const SizedBox(height: 16),

                /// 📊 STATS RAPIDES
                Wrap(
                  spacing: 12,
                  children: [
                    _statCard('Logs', loggerState.totalLogs),
                    _statCard('Actions', logStats.length),
                    _statCard('Modules', logTargets.length),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String title, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionSection(CashflowProjection projection) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Projections de Trésorerie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _projectionLine(
              'Revenu encaissé (Scellé)',
              projection.currentRevenue,
              Colors.green,
            ),
            _projectionLine(
              'Factures en attente',
              projection.pendingInvoices,
              Colors.orange,
            ),
            const Divider(),
            _projectionLine(
              'Potentiel Total',
              projection.potentialRevenue,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Avancement global chantiers : ${(projection.completionRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: projection.completionRate,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectionLine(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${amount.toStringAsFixed(2)} €',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
