import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../home/views/widgets/app_drawer.dart';
import '../../controllers/notifiers/chantiers_list_notifier.dart';

class ChantiersScreen extends ConsumerWidget {
  const ChantiersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final chantierAsync = ref.watch(chantierListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chantiers')),
      drawer: const AppDrawer(),
      body: chantierAsync.when(
        data:
            (items) => EntityList<Chantier>(
              items,
              'clients',
              onEdit: (chantier) {
                showDialog(
                  context: context,
                  builder:
                      (_) => EntityForm<Chantier>(
                        fromJson: (json) => Chantier.fromJson(json),
                        initialValue: chantier,
                        onSubmit: (updated) async {
                          await ref
                              .read(chantierListProvider.notifier)
                              .updateEntity(updated);
                        },
                        createEmpty: () => chantier,
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
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Chantier>(
                  fromJson: (json) => Chantier.fromJson(json),
                  onSubmit: (chantier) async {
                    await ref.read(chantierListProvider.notifier).add(chantier);
                  },
                  createEmpty: () => Chantier.mock(),
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
