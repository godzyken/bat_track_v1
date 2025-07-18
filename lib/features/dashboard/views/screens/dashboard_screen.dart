import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../intervention/controllers/providers/intervention_stats_provider.dart';
import '../../../intervention/views/widgets/intervention_bar_chart.dart';
import '../../../intervention/views/widgets/intervention_pie_chart.dart';
import '../widgets/dolibarr_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final statsAsync = ref.watch(interventionStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (stats) {
          final pie = InterventionPieChart(data: stats);
          final bar = InterventionBarChart(data: stats);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DolibarrSection(),
                const SizedBox(height: 16),
                if (info.screenSize == ScreenSize.tablet)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: pie),
                      const SizedBox(width: 16),
                      Expanded(child: bar),
                    ],
                  )
                else
                  Column(children: [pie, const SizedBox(height: 16), bar]),
              ],
            ),
          );
        },
      ),
    );
  }
}
