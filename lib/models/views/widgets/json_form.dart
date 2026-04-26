import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../data/local/controllers/json_form_controller.dart';
import '../../../data/local/models/adapters/json_adapter.dart';
import '../../../data/local/providers/json_form_controller_provider.dart';
import 'json_form_field.dart';

class JsonForm<T extends UnifiedModel> extends ConsumerWidget {
  final JsonAdapter<T> adapter;
  final void Function(T model)? onSubmit;
  final String submitLabel;
  final T? model;

  const JsonForm({
    super.key,
    required this.adapter,
    this.onSubmit,
    this.submitLabel = 'Enregistrer',
    this.model,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = JsonFormArgs<T>(adapter: adapter, model: model!);

    final controller = ref.watch(jsonFormControllerProvider(args));
    final notifier = ref.watch(jsonFormControllerProvider(args).notifier);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...adapter.fields.map(
            (field) => JsonFormField(
              field: field,
              value: controller.values[field.name],
              onChanged: (v) => notifier.updateField(field.name, v),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(submitLabel),
            onPressed: () {
              if (notifier.validateRequiredFields()) {
                final model = notifier.toModel() as T;
                onSubmit?.call(model);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir les champs obligatoires'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
