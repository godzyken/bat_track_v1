import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../controllers/generator/calculator.dart';

class BudgetTravauCard extends ConsumerStatefulWidget {
  final Piece piece;
  final void Function(Piece updated)? onEdit;
  final void Function(Piece piece)? onGeneratePdf;

  const BudgetTravauCard({
    super.key,
    required this.piece,
    this.onEdit,
    this.onGeneratePdf,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetTravauCardState();
}

class _BudgetTravauCardState extends ConsumerState<BudgetTravauCard> {
  late Piece piece;
  late final List<Technicien> techniciens;

  @override
  void initState() {
    super.initState();
    piece = widget.piece;
  }

  double get totalMateriaux => BudgetGen.calculerCoutMateriaux(
    piece.materiaux,
    surface: piece.surfaceM2,
  );

  double get totalMateriels => BudgetGen.calculerCoutMateriels(piece.materiels);

  double get totalMainOeuvre =>
      BudgetGen.calculerCoutMainOeuvre(piece.mainOeuvre, techniciens);

  double get total => totalMateriaux + totalMateriels + totalMainOeuvre;

  List<PieChartSectionData> _buildPieSections() {
    final totalValue = total;
    return [
      PieChartSectionData(
        value: totalMateriaux,
        title: '${(totalMateriaux / totalValue * 100).toStringAsFixed(1)}%',
        color: Colors.orange,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: totalMateriels,
        title: '${(totalMateriels / totalValue * 100).toStringAsFixed(1)}%',
        color: Colors.blue,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: totalMainOeuvre,
        title: '${(totalMainOeuvre / totalValue * 100).toStringAsFixed(1)}%',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  void _editBudget() async {
    final controller = TextEditingController(
      text: piece.mainOeuvre.heuresEstimees.toString(),
    );

    final newHours = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier le budget main-d\'œuvre'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Heures estimées'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  final hours = double.tryParse(controller.text);
                  if (hours != null) {
                    Navigator.pop(context, hours);
                  }
                },
                child: const Text('Valider'),
              ),
            ],
          ),
    );

    if (newHours != null) {
      setState(() {
        piece = piece.copyWith(
          mainOeuvre: piece.mainOeuvre.copyWith(heuresEstimees: newHours),
        );
      });
      widget.onEdit?.call(piece);
    }
  }

  void _generatePdf() {
    widget.onGeneratePdf?.call(piece);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'fr_FR');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              piece.nom,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Surface : ${piece.surfaceM2} m²",
              style: theme.textTheme.bodyMedium,
            ),
            const Divider(height: 24),
            _budgetLine(
              "Matériaux",
              totalMateriaux,
              Icons.construction,
              formatCurrency,
            ),
            _budgetLine(
              "Matériel",
              totalMateriels,
              Icons.build,
              formatCurrency,
            ),
            _budgetLine(
              "Main-d'œuvre",
              totalMainOeuvre,
              Icons.handyman,
              formatCurrency,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Budget total :",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${total.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _editBudget,
                  icon: const Icon(Icons.edit),
                  label: const Text('Éditer'),
                ),
                ElevatedButton.icon(
                  onPressed: _generatePdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetLine(
    String label,
    double amount,
    IconData icon,
    NumberFormat formatter,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            "${formatter.format(amount.toStringAsFixed(2))} €",
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
