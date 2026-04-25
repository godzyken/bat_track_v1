import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../core/riverpod/base_list_notifier.dart';
import '../../data/hive_model.dart';
import '../widgets/entity_form.dart';

class EntityScreen<T extends UnifiedModel, N extends HiveModel<T>>
    extends ConsumerWidget {
  final String title;
  final AsyncNotifierProvider<BaseListNotifier<T>, List<T>> serviceProvider;
  final T Function() createEmpty;

  const EntityScreen({
    super.key,
    required this.title,
    required this.serviceProvider,
    required this.createEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceProvider);
    final notifier = ref.read(serviceProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: state.when(
        loading: () => LoadingApp(message: 'Chargement...'),
        error: (e, _) => ErrorApp(message: "Erreur: $e"),
        data: (entities) {
          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final entity = entities[index];

              return ListTile(
                title: Text(entity.id),
                subtitle: Text(entity.updatedAt?.toIso8601String() ?? ''),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => EntityForm<T>(
                      initialValue: entity,
                      createEmpty: createEmpty,
                      fromJson: (json) => throw UnimplementedError(),
                      onSubmit: (updated) {
                        notifier.updateItem(updated);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => EntityForm<T>(
              initialValue: createEmpty(),
              createEmpty: createEmpty,
              fromJson: (json) => throw UnimplementedError(),
              onSubmit: (created) {
                notifier.addItem(created);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
