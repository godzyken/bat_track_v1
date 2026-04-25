import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../data/local/models/adapters/json_adapter.dart';
import '../widgets/json_form.dart';

class GenericEntityScreen<T extends UnifiedModel> extends ConsumerWidget {
  final JsonAdapter<T> adapter;
  final void Function(T updated)? onSubmit;
  final T? initialValue;

  const GenericEntityScreen({
    super.key,
    required this.adapter,
    this.onSubmit,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          initialValue == null
              ? 'Créer ${adapter.fields.single.name}'
              : 'Modifier ${adapter.fields.single.name}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: JsonForm<T>(
            adapter: adapter,
            onSubmit: (model) {
              if (onSubmit != null) {
                onSubmit!(model);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Formulaire soumis avec succès !'),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
