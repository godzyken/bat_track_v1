import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/json_model.dart';

typedef OnSubmit<T> = void Function(T entity);

class EntityForm<T extends JsonModel> extends ConsumerStatefulWidget {
  final T? initialValue;
  final OnSubmit<T> onSubmit;
  final T Function(Map<String, dynamic>) fromJson;

  const EntityForm({
    super.key,
    this.initialValue,
    required this.onSubmit,
    required this.fromJson,
  });

  @override
  ConsumerState<EntityForm<T>> createState() => _EntityFormState<T>();
}

class _EntityFormState<T extends JsonModel>
    extends ConsumerState<EntityForm<T>> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  late Map<String, dynamic> _json;

  @override
  void initState() {
    super.initState();
    _json = widget.initialValue?.toJson() ?? {};
    for (var entry in _json.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updatedJson = {
      for (var entry in _controllers.entries)
        entry.key: _parseValue(entry.key, entry.value.text),
    };

    final updatedEntity = widget.fromJson(updatedJson);
    widget.onSubmit(updatedEntity);
    context.pop();
  }

  dynamic _parseValue(String key, String value) {
    final original = _json[key];
    if (original is DateTime) {
      return DateTime.tryParse(value);
    } else if (original is int) {
      return int.tryParse(value);
    } else if (original is double) {
      return double.tryParse(value);
    } else if (original is List) {
      return value.split(',').map((e) => e.trim()).toList();
    }
    return value; // default: String
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialValue == null ? 'Créer' : 'Modifier'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children:
                _controllers.entries.map((entry) {
                  final label = entry.key;
                  final controller = entry.value;
                  final isRequired = label == 'nom' || label == 'titre';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(labelText: label),
                      validator: (value) {
                        if (isRequired && (value == null || value.isEmpty)) {
                          return 'Champ requis';
                        }
                        return null;
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Valider')),
      ],
    );
  }
}
