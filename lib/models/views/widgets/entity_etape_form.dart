import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/models/chantier_etapes.dart';

typedef OnEtapeSubmit = void Function(ChantierEtape etape);

class EntityEtapeForm extends StatefulWidget {
  final ChantierEtape? initialValue;
  final OnEtapeSubmit onSubmit;

  const EntityEtapeForm({super.key, this.initialValue, required this.onSubmit});

  @override
  State<EntityEtapeForm> createState() => _EntityEtapeFormState();
}

class _EntityEtapeFormState extends State<EntityEtapeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateDebutController;
  late final TextEditingController _dateFinController;

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
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
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
    );
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialValue == null ? 'Nouvelle étape' : 'Modifier l\'étape',
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
