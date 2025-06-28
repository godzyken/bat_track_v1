import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterventionPieChart extends ConsumerWidget {
  final Map<String, int> data;
  final bool isCompact;

  const InterventionPieChart({
    super.key,
    required this.data,
    this.isCompact = false,
  });

  static final List<Color> defaultColors = [
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = data.values.fold(0, (sum, val) => sum + val);

    final sections =
        data.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final value = e.value.toDouble();
          final percentage =
              total == 0 ? 0 : (value / total * 100).toStringAsFixed(1);

          return PieChartSectionData(
            value: value,
            color:
                value == 0
                    ? Colors.grey.shade300
                    : defaultColors[index % defaultColors.length],
            title: value == 0 ? '' : '$percentage%',
            radius: isCompact ? 30 : 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    final legendItems =
        data.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          final color =
              e.value == 0
                  ? Colors.grey.shade300
                  : defaultColors[index % defaultColors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(width: 12, height: 12, color: color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${e.key} (${e.value})',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList();

    if (isCompact) {
      return _buildCompactBarChart();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Répartition des interventions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 4,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact horizontal bar chart
  Widget _buildCompactBarChart() {
    final maxValue =
        data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);

    final barGroups =
        data.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: defaultColors[index % defaultColors.length],
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= data.length) return const SizedBox();
                      return Text(
                        data.keys.elementAt(index),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              maxY: maxValue.toDouble() + 1,
            ),
          ),
        ),
      ),
    );
  }
}
