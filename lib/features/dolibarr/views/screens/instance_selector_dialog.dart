import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/remote/providers/dolibarr_instance_provider.dart';

class InstanceSelectorDialog extends ConsumerWidget {
  const InstanceSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instancesAsync = ref.watch(dolibarrInstancesProvider);

    return AlertDialog(
      title: const Text('Choisir une instance Dolibarr'),
      content: instancesAsync.when(
        data: (instances) {
          if (instances.isEmpty) {
            return const Text('Aucune instance configurée.');
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children:
                instances
                    .map(
                      (instance) => ListTile(
                        title: Text(instance.name),
                        subtitle: Text(instance.baseUrl),
                        onTap: () async {
                          await ref
                              .read(selectedInstanceProvider.notifier)
                              .selectInstance(instance);
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/home');
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )
                    .toList(),
          );
        },
        loading: () => const LoadingApp(),
        error:
            (err, _) => ErrorApp(
              message:
                  "Erreur lors de la connection au profile administrateur : $err",
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
