import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../intervention/controllers/providers/intervention_stats_provider.dart';
import '../../../intervention/views/widgets/intervention_bar_chart.dart';
import '../../../intervention/views/widgets/intervention_pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(interventionStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (stats) {
          final isLargeScreen = MediaQuery.of(context).size.width > 600;

          final pie = InterventionPieChart(data: stats);
          final bar = InterventionBarChart(data: stats);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child:
                isLargeScreen
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: pie),
                        const SizedBox(width: 16),
                        Expanded(child: bar),
                      ],
                    )
                    : Column(children: [pie, const SizedBox(height: 16), bar]),
          );
        },
      ),
    );
  }
}
