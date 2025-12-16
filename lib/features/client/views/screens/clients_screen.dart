import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../controllers/notifiers/clients_list_notifier.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final clientsAsync = ref.watch(clientListProvider);
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAdmin = user.role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: EntityList<Client>(
        items: clientsAsync,
        boxName: 'clients',
        infoOverride: info,
        onCreate:
            isAdmin
                ? () {
                  showEntityFormDialog<Client>(
                    context: context,
                    ref: ref,
                    role: user.role,
                    onSubmit: (client) async {
                      await clientService.save(client);
                    },
                    fromJson: Client.fromJson,
                    createEmpty: Client.mock,
                  );
                }
                : () {},
        onEdit: (client) {
          showEntityFormDialog<Client>(
            context: context,
            ref: ref,
            role: user.role,
            onSubmit: (updated) async {
              await clientService.sync(updated);
            },
            fromJson: Client.fromJson,
            createEmpty: Client.mock,
          );
        },
        onDelete: isAdmin ? (id) => clientService.delete(id) : null,
        readOnly: !isAdmin,
        currentRole: user.role,
        currentUserId: user.id,
        policy: MultiRolePolicy(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Client>(
                  fromJson: (json) => Client.fromJson(json),
                  onSubmit: (client) async {
                    await ref.read(clientListProvider.notifier).add(client);
                  },
                  createEmpty: () => Client.mock(),
                ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
