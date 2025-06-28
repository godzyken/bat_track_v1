import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InterventionBarChart extends StatelessWidget {
  final Map<String, int> data;
  final bool isCompact;

  const InterventionBarChart({
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
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible.'));
    }

    final bars = data.entries.toList();
    final maxY = data.values.reduce((a, b) => a > b ? a : b).toDouble();

    // Intervalle lisible
    double interval;
    if (maxY <= 5) {
      interval = 1;
    } else if (maxY <= 10) {
      interval = 2;
    } else if (maxY <= 25) {
      interval = 5;
    } else if (maxY <= 50) {
      interval = 10;
    } else {
      interval = 20;
    }

    final barGroups =
        bars.asMap().entries.map((entry) {
          final index = entry.key;
          final e = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                width: 16,
                color: defaultColors[index % defaultColors.length],
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList();

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
            SizedBox(
              height: isCompact ? 16.0 * data.length + 80 : 240,
              child: BarChart(
                BarChartData(
                  maxY: maxY + interval,
                  barTouchData: BarTouchData(enabled: false),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    // === COMPACT : axes inversés ===
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: isCompact ? false : true,
                        interval: interval,
                        reservedSize: 32,
                        getTitlesWidget:
                            (value, _) => Text(
                              value % interval == 0
                                  ? value.toInt().toString()
                                  : '',
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
                          if (index >= bars.length) return const SizedBox();
                          return Text(
                            bars[index].key,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    // === COMPACT : affichage label à gauche ===
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: isCompact,
                        reservedSize: 90,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= bars.length) return const SizedBox();
                          return Text(
                            bars[index].key,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
