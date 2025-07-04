import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/models/index_model_extention.dart';
import '../../../data/local/providers/hive_provider.dart';
import '../../../features/documents/controllers/generator/budget_service.dart';

typedef OnEtapeSubmit = void Function(ChantierEtape etape);

class EntityEtapeForm extends ConsumerStatefulWidget {
  final ChantierEtape? initialValue;
  final OnEtapeSubmit onSubmit;
  final Client client;
  final List<ChantierEtape>? autresEtapes; // Étapes déjà existantes

  const EntityEtapeForm({
    super.key,
    this.initialValue,
    required this.onSubmit,
    required this.client,
    this.autresEtapes,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EntityEtapeFormState();
}

class _EntityEtapeFormState extends ConsumerState<EntityEtapeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateDebutController;
  late final TextEditingController _dateFinController;
  late final TextEditingController _budgetController;
  double? _budgetEtape;

  @override
  void initState() {
    super.initState();
    final etape = widget.initialValue;
    _titreController = TextEditingController(text: etape?.titre ?? '');
    _descriptionController = TextEditingController(
      text: etape?.description ?? '',
    );
    _dateDebutController = TextEditingController(
      text: etape?.dateDebut?.toIso8601String() ?? '',
    );
    _dateFinController = TextEditingController(
      text: etape?.dateFin?.toIso8601String() ?? '',
    );
    _budgetEtape = etape?.budget;
    _budgetController = TextEditingController(
      text: _budgetEtape?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final newEtape = ChantierEtape(
      id: widget.initialValue?.id ?? const Uuid().v4(),
      titre: _titreController.text,
      description: _descriptionController.text,
      dateDebut: DateTime.tryParse(_dateDebutController.text),
      dateFin: DateTime.tryParse(_dateFinController.text),
      budget: _budgetEtape,
    );
    final technicien = ref.watch(technicienProvider(newEtape.chantierId!));
    final bool isInBudget = BudgetService.estEtapeDansBudget(
      widget.client,
      newEtape,
      widget.autresEtapes!,
      technicien == null ? [] : [technicien],
    );

    if (!isInBudget) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Dépassement de budget'),
              content: const Text(
                "Cette étape dépasse le budget prévisionnel du client.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    widget.onSubmit(newEtape);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      controller.text = date.toIso8601String();
    }
  }

  List<PieChartSectionData> _buildPieSections(
    double budgetAlloue,
    double budgetConsomme,
    double restant,
  ) {
    return [
      PieChartSectionData(
        value: budgetAlloue,
        color: Colors.green,
        title: 'Alloué',
        radius: 40,
      ),
      PieChartSectionData(
        value: budgetConsomme,
        color: Colors.orange,
        title: 'Consommé',
        radius: 40,
      ),
      PieChartSectionData(
        value: restant,
        color: Colors.red,
        title: 'Restant',
        radius: 40,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tech = ref.watch(technicienBoxProvider).get(ref);
    final budgetTotal = widget.client.budgetPrevu;
    final budgetConsomme = widget.autresEtapes?.fold(
      0.0,
      (total, e) => total + BudgetService.calculerBudgetEtape(e, [tech!]),
    );
    final budgetRestant = budgetTotal! - budgetConsomme!;

    return AlertDialog(
      title: Text(
        widget.initialValue == null ? 'Nouvelle étape' : "Modifier l'étape",
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator:
                    (value) => value == null || value.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateDebutController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(_dateDebutController),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateFinController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date de fin',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(_dateFinController),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: "Budget de l'étape (€)",
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged:
                    (value) =>
                        setState(() => _budgetEtape = double.tryParse(value)),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) return 'Valeur invalide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Budget restant : ${budgetRestant.toStringAsFixed(2)} €',
                style: TextStyle(
                  color: budgetRestant >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Répartition du budget'),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieSections(
                      budgetTotal,
                      budgetConsomme,
                      budgetRestant < 0 ? 0 : budgetRestant,
                    ),
                    centerSpaceRadius: 30,
                    sectionsSpace: 4,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Valider')),
      ],
    );
  }
}
