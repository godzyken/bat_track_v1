import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/remote/providers/dolibarr_instance_provider.dart';
import 'instance_selector_dialog.dart';

class DolibarrSection extends ConsumerWidget {
  final VoidCallback? onSync;

  const DolibarrSection({super.key, this.onSync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instance = ref.watch(selectedInstanceProvider);

    return instance == null
        ? const Text('⚠️ Aucune instance Dolibarr sélectionnée.')
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    instance.name.isEmpty
                        ? '⚠️ Aucune instance Dolibarr sélectionnée.'
                        : 'Instance : ${instance.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Changer d\'instance',
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const InstanceSelectorDialog(),
                    );
                  },
                ),
              ],
            ),
            if (instance.name.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('URL : ${instance.baseUrl}'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Synchroniser avec Dolibarr'),
                onPressed: () async {
                  onSync?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Synchronisation lancée.')),
                  );
                },
              ),
            ],
          ],
        );
  }
}
