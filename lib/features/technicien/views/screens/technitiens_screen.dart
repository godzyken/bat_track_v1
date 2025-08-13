import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../auth/data/providers/auth_state_provider.dart';
import '../../../home/views/widgets/app_drawer.dart';
import '../../controllers/notifiers/technicien_list_notifier.dart';

class TechniciensScreen extends ConsumerWidget {
  const TechniciensScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final techniciensAsync = ref.watch(techniciensListProvider);
    final user = ref.watch(appUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = user.role == 'admin';
    final isTech = user.role == 'tech';

    return Scaffold(
      appBar: AppBar(title: const Text('Techniciens')),
      drawer: const AppDrawer(),
      body: EntityList<Technicien>(
        items: techniciensAsync,
        boxName: 'techniciens',
        onCreate:
            isAdmin
                ? () {
                  showEntityFormDialog<Technicien>(
                    context: context,
                    ref: ref,
                    role: user.role,
                    onSubmit: (technicien) async {
                      await technicienService.save(technicien, technicien.id);
                    },
                    fromJson: Technicien.fromJson,
                    createEmpty: Technicien.mock,
                  );
                }
                : () {},
        onEdit: (technicien) {
          showEntityFormDialog<Technicien>(
            context: context,
            ref: ref,
            role: user.role,
            onSubmit: (updated) async {
              await technicienService.update(updated, technicien.id);
            },
            fromJson: Technicien.fromJson,
            createEmpty: Technicien.mock,
          );
        },
        onDelete: isAdmin ? (id) => technicienService.delete(id) : null,
        readOnly: !isAdmin && !isTech,
        currentRole: user.role,
        currentUserId: user.id,
        policy: MultiRolePolicy(),
        infoOverride: info,
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
