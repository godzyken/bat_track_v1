import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_state_provider.dart';

class MultiUserDropdownField extends ConsumerWidget {
  final List<String> selectedUserIds;
  final void Function(List<String>) onChanged;
  final String? companyId; // restriction éventuelle
  final String role; // 'technicien', 'client', etc.
  final String label;

  const MultiUserDropdownField({
    super.key,
    required this.selectedUserIds,
    required this.onChanged,
    required this.role,
    this.companyId,
    this.label = 'Techniciens assignés',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersByRoleProvider(role)); // crée ce provider

    return usersAsync.when(
      data: (users) {
        final filtered =
            companyId != null
                ? users.where((u) => u.company == companyId).toList()
                : users;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Wrap(
              spacing: 8,
              children:
                  filtered.map((user) {
                    final isSelected = selectedUserIds.contains(user.id);
                    return FilterChip(
                      label: Text(user.name ?? user.email),
                      selected: isSelected,
                      onSelected: (selected) {
                        final updated = List<String>.from(selectedUserIds);
                        if (selected) {
                          updated.add(user.id);
                        } else {
                          updated.remove(user.id);
                        }
                        onChanged(updated);
                      },
                    );
                  }).toList(),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Erreur: $e"),
    );
  }
}
