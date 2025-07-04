import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetDetailSansTech extends ConsumerWidget {
  final Map<String, double> details;

  const BudgetDetailSansTech({super.key, required this.details});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = details.values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détail du budget',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildPieChart(details, total)),
            const SizedBox(width: 24),
            Expanded(child: _buildLegend(details, total)),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, double> data, double total) {
    final colors = [Colors.blue, Colors.orange, Colors.green];

    return PieChart(
      PieChartData(
        sections:
            data.entries.mapIndexed((i, e) {
              final value = e.value;
              final percentage = total > 0 ? (value / total * 100) : 0;
              return PieChartSectionData(
                value: value,
                title: "${percentage.toStringAsFixed(1)}%",
                color: colors[i % colors.length],
                radius: 50,
                titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
        sectionsSpace: 4,
        centerSpaceRadius: 30,
      ),
    );
  }

  Widget _buildLegend(Map<String, double> data, double total) {
    final colors = [Colors.blue, Colors.orange, Colors.green];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          data.entries.mapIndexed((i, e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: colors[i % colors.length],
                  ),
                  const SizedBox(width: 8),
                  Text("${e.key}: ${e.value.toStringAsFixed(2)} €"),
                ],
              ),
            );
          }).toList(),
    );
  }
}
