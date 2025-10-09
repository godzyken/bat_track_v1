import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum InterventionChartType { bar, pie }

class AnimatedInterventionChart extends StatefulWidget {
  final Map<String, int> data;
  final bool isCompact;

  const AnimatedInterventionChart({
    super.key,
    required this.data,
    this.isCompact = false,
  });

  @override
  State<AnimatedInterventionChart> createState() =>
      _AnimatedInterventionChartState();
}

class _AnimatedInterventionChartState extends State<AnimatedInterventionChart>
    with SingleTickerProviderStateMixin {
  InterventionChartType _chartType = InterventionChartType.bar;

  late AnimationController _controller;
  late Animation<double> _animation;

  Map<String, int> _oldData = {};

  static final List<Color> defaultColors = [
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _oldData = Map.from(widget.data);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedInterventionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _oldData = Map.from(oldWidget.data);
      _controller
        ..reset()
        ..forward();
    }
  }

  void _toggleChartType() {
    _controller.reset();
    setState(() {
      _chartType =
          _chartType == InterventionChartType.bar
              ? InterventionChartType.pie
              : InterventionChartType.bar;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(int index) => defaultColors[index % defaultColors.length];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible.'));
    }

    final bars = widget.data.entries.toList();
    final maxY = widget.data.values.reduce((a, b) => a > b ? a : b).toDouble();

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
    interval = interval.clamp(1, 20);

    double animatedValue(String key) {
      final oldVal = _oldData[key]?.toDouble() ?? 0;
      final newVal = widget.data[key]?.toDouble() ?? 0;
      return oldVal + (newVal - oldVal) * _animation.value;
    }

    Widget buildBarChart() {
      final barGroups =
          bars.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: animatedValue(e.key),
                  width: 16,
                  color: _getColor(index),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList();

      return BarChart(
        BarChartData(
          maxY: maxY + interval,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !widget.isCompact,
                interval: interval,
                reservedSize: 32,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !widget.isCompact,
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
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      );
    }

    Widget buildPieChart() {
      final total = widget.data.values.fold<int>(0, (p, e) => p + e);
      return PieChart(
        PieChartData(
          sections:
              bars.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                return PieChartSectionData(
                  color: _getColor(index),
                  value: animatedValue(e.key),
                  title: '${((e.value / total) * 100).toStringAsFixed(1)}%',
                  radius: widget.isCompact ? 30 : 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: widget.isCompact ? 20 : 40,
        ),
      );
    }

    Widget buildLegend() {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        children:
            bars.asMap().entries.map((entry) {
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
            }).toList(),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Interventions par statut',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _chartType == InterventionChartType.bar
                        ? Icons.pie_chart
                        : Icons.bar_chart,
                  ),
                  onPressed: _toggleChartType,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _animation,
              builder:
                  (_, _) => SizedBox(
                    height:
                        _chartType == InterventionChartType.bar
                            ? (widget.isCompact
                                ? 16.0 * widget.data.length + 80
                                : 240)
                            : 240,
                    child:
                        _chartType == InterventionChartType.bar
                            ? buildBarChart()
                            : buildPieChart(),
                  ),
            ),
            const SizedBox(height: 12),
            buildLegend(),
          ],
        ),
      ),
    );
  }
}
