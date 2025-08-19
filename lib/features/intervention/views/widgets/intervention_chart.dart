import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum InterventionChartType { bar, pie }

class InterventionChart extends StatelessWidget {
  final Map<String, int> data;
  final InterventionChartType chartType;
  final bool isCompact;

  const InterventionChart({
    super.key,
    required this.data,
    this.chartType = InterventionChartType.bar,
    this.isCompact = false,
  });

  static final List<Color> defaultColors = [
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.blueGrey,
  ];

  Color _getColor(int index) => defaultColors[index % defaultColors.length];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty)
      return const Center(child: Text('Aucune donnée disponible.'));

    final entries = data.entries.toList();
    final maxY = data.values.reduce((a, b) => a > b ? a : b).toDouble();

    double interval;
    if (maxY <= 5)
      interval = 1;
    else if (maxY <= 10)
      interval = 2;
    else if (maxY <= 25)
      interval = 5;
    else if (maxY <= 50)
      interval = 10;
    else
      interval = 20;

    Widget _buildBarChart() {
      final barGroups =
          entries.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: e.value.toDouble(),
                  width: 16,
                  color: _getColor(index),
                  borderRadius: BorderRadius.circular(4),
                  rodStackItems: [],
                ),
              ],
            );
          }).toList();

      return BarChart(
        BarChartData(
          maxY: maxY + interval,
          barGroups: barGroups,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !isCompact,
                interval: interval,
                reservedSize: 32,
                getTitlesWidget:
                    (value, _) => Text(
                      value % interval == 0 ? value.toInt().toString() : '',
                      style: const TextStyle(fontSize: 10),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !isCompact,
                reservedSize: 42,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= entries.length) return const SizedBox();
                  return Text(
                    entries[index].key,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      );
    }

    Widget _buildPieChart() {
      final total = data.values.fold<int>(0, (p, e) => p + e);
      return PieChart(
        PieChartData(
          sections:
              entries.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                return PieChartSectionData(
                  color: _getColor(index),
                  value: e.value.toDouble(),
                  title: '${((e.value / total) * 100).toStringAsFixed(1)}%',
                  radius: isCompact ? 30 : 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: isCompact ? 20 : 40,
        ),
      );
    }

    Widget _buildLegend(bool isHorizontal) {
      final legendItems =
          entries.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColor(index),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(e.key, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList();

      return isHorizontal
          ? Wrap(spacing: 8, runSpacing: 4, children: legendItems)
          : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legendItems,
          );
    }

    final isWide = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interventions par statut',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (_, value, __) {
                if (chartType == InterventionChartType.bar) {
                  return SizedBox(
                    height: isCompact ? 16.0 * data.length + 80 : 240,
                    child: _buildBarChart(),
                  );
                } else {
                  return SizedBox(height: 240, child: _buildPieChart());
                }
              },
            ),
            const SizedBox(height: 12),
            _buildLegend(isWide),
          ],
        ),
      ),
    );
  }
}
