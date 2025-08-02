import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/views/widgets/entity_form.dart';
import '../../../../models/views/widgets/entity_list.dart';
import '../../../home/views/widgets/app_drawer.dart';
import '../../controllers/notifiers/clients_list_notifier.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);
    final clientsAsync = ref.watch(clientListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      drawer: const AppDrawer(),
      body: EntityList<Client>(
        items: clientsAsync,
        boxName: 'clients',
        onEdit: (client) {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<Client>(
                  fromJson: (json) => Client.fromJson(json),
                  initialValue: client,
                  onSubmit: (updated) async {
                    await ref
                        .read(clientListProvider.notifier)
                        .updateEntity(updated);
                  },
                  createEmpty: () => Client.mock(),
                ),
          );
        },
        onDelete: (id) async {
          await ref
              .read(firestoreProvider)
              .collection('clients')
              .doc(id)
              .delete();
        },
        infoOverride: info,
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
