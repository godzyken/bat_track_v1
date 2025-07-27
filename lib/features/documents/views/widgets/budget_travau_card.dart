import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../technicien/controllers/providers/technicien_providers.dart';
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

  @override
  void initState() {
    super.initState();
    piece = widget.piece;
  }

  void _editBudget(List<Technicien> techniciens) async {
    final controllerMap = {
      for (final mo in piece.mainOeuvre ?? [])
        mo.idTechnicien: TextEditingController(
          text: mo.heuresEstimees.toString(),
        ),
    };

    final newValues = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier les heures estimées"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  piece.mainOeuvre!.map((mo) {
                    final tech = techniciens.firstWhere(
                      (t) => t.id == mo.idTechnicien,
                      orElse: () => Technicien.mock(),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: controllerMap[mo.idTechnicien],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '${tech.nom} (heures)',
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final result = <String, double>{};
                for (final entry in controllerMap.entries) {
                  final parsed = double.tryParse(entry.value.text);
                  if (parsed != null) {
                    result[entry.key] = parsed;
                  }
                }
                Navigator.pop(context, result);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    if (newValues != null) {
      final updatedMainOeuvre =
          piece.mainOeuvre!.map((mo) {
            final heures = newValues[mo.idTechnicien];
            return heures != null ? mo.copyWith(heuresEstimees: heures) : mo;
          }).toList();

      setState(() {
        piece = piece.copyWith(mainOeuvre: updatedMainOeuvre);
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
    final techniciensAsync = ref.watch(
      techniciensStreamProvider,
    ); // À adapter à ton provider réel

    return techniciensAsync.when(
      data: (techniciens) {
        final totalMateriaux = BudgetGen.calculerCoutMateriaux(
          piece.materiaux ?? [],
          surface: piece.surface,
        );
        final totalMateriels = BudgetGen.calculerCoutMateriels(
          piece.materiels ?? [],
        );
        final totalMainOeuvre = BudgetGen.estimationCoutTotalMainOeuvre(
          piece.mainOeuvre ?? [],
          techniciens,
        );
        final total = totalMateriaux + totalMateriels + totalMainOeuvre;

        List<PieChartSectionData> buildPieSections() {
          if (total == 0) return [];
          return [
            PieChartSectionData(
              value: totalMateriaux,
              title: '${(totalMateriaux / total * 100).toStringAsFixed(1)}%',
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
              title: '${(totalMateriels / total * 100).toStringAsFixed(1)}%',
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
              title: '${(totalMainOeuvre / total * 100).toStringAsFixed(1)}%',
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

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                  "Surface : ${piece.surface} m²",
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      sections: buildPieSections(),
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
                      onPressed: () => _editBudget(techniciens),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur de chargement : $e')),
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
