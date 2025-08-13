import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntityEtapeForm<T> extends ConsumerStatefulWidget {
  final T? initialValue;
  final void Function(T etape) onSubmit;
  final T Function(Map<String, dynamic> json) fromJson;
  final T Function() createEmpty;

  const EntityEtapeForm({
    super.key,
    required this.initialValue,
    required this.onSubmit,
    required this.fromJson,
    required this.createEmpty,
  });

  @override
  ConsumerState<EntityEtapeForm<T>> createState() => _EntityEtapeFormState<T>();
}

class _EntityEtapeFormState<T> extends ConsumerState<EntityEtapeForm<T>> {
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, dynamic> _formValues;
  final _formKey = GlobalKey<FormState>();
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    final value =
        widget.initialValue ?? widget.createEmpty(); // fallback to default mock

    final map = (value as dynamic).toJson() as Map<String, dynamic>;

    _formValues = {...map};
    _controllers = {
      for (final entry in map.entries)
        if (_isSimpleField(entry.value))
          entry.key: TextEditingController(text: entry.value?.toString() ?? ''),
    };
  }

  bool _isSimpleField(dynamic value) =>
      value == null || value is String || value is num || value is bool;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nouvelle étape"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children:
                _formValues.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;

                  if (!_showAdvanced &&
                      !_isSimpleField(value) &&
                      key != 'dateDebut' &&
                      key != 'dateFin') {
                    return const SizedBox.shrink();
                  }

                  if (_controllers.containsKey(key)) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: TextFormField(
                        controller: _controllers[key],
                        decoration: InputDecoration(labelText: key),
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Champ requis'
                                    : null,
                      ),
                    );
                  }

                  if (value is String && key.toLowerCase().contains('date')) {
                    DateTime? parsedDate;
                    try {
                      parsedDate = DateTime.tryParse(value);
                    } catch (_) {}
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InputDatePickerFormField(
                        initialDate: parsedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        fieldLabelText: key,
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
          onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
          child: Text(_showAdvanced ? "Cacher expert" : "Mode expert"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final json = {
              ..._formValues,
              for (final entry in _controllers.entries)
                entry.key: entry.value.text,
            };

            final parsed = widget.fromJson(json);
            widget.onSubmit(parsed);
            Navigator.of(context).pop();
          },
          child: const Text("Valider"),
        ),
      ],
    );
  }
}
