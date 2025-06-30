import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/json_model.dart';

class EntityDetailScreen<T extends JsonModel> extends ConsumerWidget {
  final T entity;

  const EntityDetailScreen({super.key, required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails de ${entity.runtimeType}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(entity.toJson().toString()),
      ),
    );
  }
}
