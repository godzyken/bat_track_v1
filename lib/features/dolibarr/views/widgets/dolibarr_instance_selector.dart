import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/remote/providers/dolibarr_instance_provider.dart';
import '../../../../data/remote/services/dolibarr_loader.dart';

class DolibarrInstanceSelector extends ConsumerWidget {
  final List<DolibarrInstance> availableInstances;

  const DolibarrInstanceSelector({super.key, required this.availableInstances});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedInstanceProvider);

    return DropdownButton<DolibarrInstance>(
      value: selected,
      hint: const Text('Sélectionnez une instance Dolibarr'),
      items:
          availableInstances.map((instance) {
            return DropdownMenuItem(
              value: instance,
              child: Text(instance.name),
            );
          }).toList(),
      onChanged: (newInstance) {
        if (newInstance != null) {
          ref
              .read(selectedInstanceProvider.notifier)
              .selectInstance(newInstance);
        }
      },
    );
  }
}
