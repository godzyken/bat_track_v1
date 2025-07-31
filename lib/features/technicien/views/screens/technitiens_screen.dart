import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../home/views/widgets/app_drawer.dart';
import '../../controllers/notifiers/technicien_list_notifier.dart';

class TechniciensScreen extends ConsumerWidget {
  const TechniciensScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final techniciensAsync = ref.watch(techniciensListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Techniciens')),
      drawer: const AppDrawer(),
      body: techniciensAsync.when(
        data:
            (items) => EntityList<Technicien>(
              items,
              'techniciens',
              onEdit: (tech) {
                showDialog(
                  context: context,
                  builder:
                      (_) => EntityForm<Technicien>(
                        fromJson: (json) => Technicien.fromJson(json),
                        initialValue: tech,
                        onSubmit: (updated) async {
                          await ref
                              .read(techniciensListProvider.notifier)
                              .updateEntity(updated);
                        },
                        createEmpty: () => Technicien.mock(),
                      ),
                );
              },
              info: info,
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(techniciensListProvider.notifier).add(Technicien.mock());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
