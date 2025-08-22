import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/local/providers/hive_provider.dart';
import '../../../../data/remote/providers/dolibarr_instance_provider.dart';
import '../../../../data/remote/services/dolibarr_loader.dart';
import '../../../auth/data/providers/current_user_provider.dart';

class PickInstanceScreen extends ConsumerWidget {
  const PickInstanceScreen({super.key});

  Future<void> onInstanceSelected(
    BuildContext context,
    WidgetRef ref,
    DolibarrInstance instance,
  ) async {
    // 1. Sélectionner l'instance
    await ref.read(selectedInstanceProvider.notifier).selectInstance(instance);

    // 2. Mettre à jour l'utilisateur avec l'instance
    final user = ref.read(currentUserLoaderProvider).value;
    if (user != null) {
      final updatedUser = user.copyWith(instanceId: instance.name);

      final userBox = ref.read(userBoxProvider);
      await userBox.put(updatedUser.id, updatedUser);

      ref.read(currentUserStateProvider.notifier).state =
          updatedUser.toAppUser();
    }

    // 3. Naviguer
    if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simule des instances Dolibarr
    final instances = [
      DolibarrInstance(
        name: 'Instance 1',
        baseUrl: 'https://url1.com',
        apiKey: 'api1',
      ),
      DolibarrInstance(
        name: 'Instance 2',
        baseUrl: 'https://url2.com',
        apiKey: 'api2',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choisir une instance')),
      body: ListView.builder(
        itemCount: instances.length,
        itemBuilder: (context, index) {
          final instance = instances[index];
          return ListTile(
            title: Text(instance.name),
            onTap: () => onInstanceSelected(context, ref, instance),
          );
        },
      ),
    );
  }
}
