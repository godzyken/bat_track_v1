import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/data/local/models/base/access_policy_interface.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/features/equipement/controllers/notifiers/equipements_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';

class EquipementScreen extends ConsumerWidget {
  const EquipementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final equipementAsync = ref.watch(equipementListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Équipements')),
      body: EntityList<Equipement>(
        items: equipementAsync,
        boxName: 'equipements',
        onEdit: (equipement) {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Equipement>(
                  fromJson: (json) => Equipement.fromJson(json),
                  initialValue: equipement,
                  onSubmit: (updated) async {
                    await ref
                        .read(equipementListProvider.notifier)
                        .updateEntity(updated);
                  },
                  createEmpty: () => equipement,
                ),
          );
        },
        onDelete: (id) async {
          await ref
              .read(firestoreProvider)
              .collection('equipements')
              .doc(id)
              .delete();
        },
        infoOverride: info,
        policy: MultiRolePolicy(),
        currentRole: '',
        currentUserId: '',
        onCreate: () {},
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {Equipement? initial}) {
    showDialog(
      context: context,
      builder:
          (_) => EntityForm<Equipement>(
            initialValue: initial,
            fromJson: (json) => Equipement.fromJson(json),
            createEmpty: () => Equipement.mock(),
            onSubmit: (e) => ref.read(equipementListProvider.notifier).add(e),
          ),
    );
  }
}
