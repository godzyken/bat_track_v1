import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/views/screens/exeception_screens.dart';
import '../../../dolibarr/views/widgets/dolibarr_section.dart';
import '../../../intervention/controllers/providers/intervention_stats_provider.dart';
import '../../../intervention/views/widgets/intervention_chart.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: statsAsync.when(
        loading: () => const LoadingApp(),
        error:
            (e, _) => ErrorApp(
              message: "Erreur lors de la connexion au dashboard : $e",
            ),
        data: (stats) {
          // Filtrage dynamique selon projet/chantier
          final projets = stats.keys.toList();
          final filteredChantiers =
              selectedProjectId != null
                  ? stats[selectedProjectId!]!.keys.toList()
                  : stats.values.expand((e) => e.keys).toSet().toList();

          // Données filtrées pour les graphiques
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

          final pieChart = AnimatedInterventionChart(data: pieData);

          final barChart = AnimatedInterventionChart(data: barData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DolibarrSection(),
                const SizedBox(height: 16),

                // Barre de projets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous les projets'),
                        selected: selectedProjectId == null,
                        onSelected: (_) {
                          setState(() {
                            selectedProjectId = null;
                            selectedChantierId = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...projets.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
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

                // Barre de chantiers
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous les chantiers'),
                        selected: selectedChantierId == null,
                        onSelected: (_) {
                          setState(() {
                            selectedChantierId = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...filteredChantiers.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
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

                // Graphiques
                if (info.screenSize == ScreenSize.tablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: pieChart),
                      const SizedBox(width: 16),
                      Expanded(child: barChart),
                    ],
                  )
                else
                  Column(
                    children: [pieChart, const SizedBox(height: 16), barChart],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
