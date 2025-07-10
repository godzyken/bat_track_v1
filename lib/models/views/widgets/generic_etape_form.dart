import 'package:flutter/material.dart';

/// Formulaire générique pour toute entité d'étape : ChantierEtape, InterventionEtape, etc.
class GenericEtapeForm<T> extends StatefulWidget {
  final T? initialValue;
  final void Function(T etape) onSubmit;
  final T Function(Map<String, dynamic>) fromJson;
  final T Function() createEmpty;

  const GenericEtapeForm({
    super.key,
    required this.initialValue,
    required this.onSubmit,
    required this.fromJson,
    required this.createEmpty,
  });

  @override
  State<GenericEtapeForm<T>> createState() => _GenericEtapeFormState<T>();
}

class _GenericEtapeFormState<T> extends State<GenericEtapeForm<T>> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formValues;
  late Map<String, TextEditingController> _controllers;
  bool _showExpert = false;

  @override
  void initState() {
    super.initState();

    final instance = widget.initialValue ?? widget.createEmpty();
    final json = (instance as dynamic).toJson() as Map<String, dynamic>;
    _formValues = {...json};

    _controllers = {
      for (final entry in json.entries)
        if (_isSimple(entry.value))
          entry.key: TextEditingController(text: entry.value?.toString() ?? ''),
    };
  }

  bool _isSimple(dynamic value) =>
      value == null || value is String || value is num || value is bool;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialValue == null ? 'Nouvelle étape' : 'Modifier étape',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children:
                _formValues.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;

                  if (!_showExpert && !_isSimple(value) && !_isDateField(key)) {
                    return const SizedBox.shrink();
                  }

                  if (_controllers.containsKey(key)) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TextFormField(
                        controller: _controllers[key],
                        decoration: InputDecoration(
                          labelText: _formatLabel(key),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Champ requis' : null,
                      ),
                    );
                  }

                  if (_isDateField(key)) {
                    final initialDate = _parseDate(value?.toString());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: InputDatePickerFormField(
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: initialDate ?? DateTime.now(),
                        fieldLabelText: _formatLabel(key),
                        onDateSubmitted: (date) {
                          _formValues[key] = date.toIso8601String();
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _showExpert = !_showExpert),
          child: Text(_showExpert ? 'Mode simple' : 'Mode expert'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Valider')),
      ],
    );
  }

  String _formatLabel(String key) {
    return key.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2').capitalize();
  }

  DateTime? _parseDate(String? raw) {
    try {
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  bool _isDateField(String key) =>
      key.toLowerCase().contains('date') ||
      key.toLowerCase().startsWith('jour');

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final json = {
      ..._formValues,
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };

    final result = widget.fromJson(json);
    widget.onSubmit(result);
    Navigator.pop(context);
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
