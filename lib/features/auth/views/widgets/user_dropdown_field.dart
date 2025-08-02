import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_state_provider.dart';

class UserDropdownField extends ConsumerWidget {
  final String role;
  final String? selectedUserId;
  final void Function(String?) onChanged;
  final String label;

  const UserDropdownField({
    super.key,
    required this.role,
    required this.onChanged,
    required this.label,
    this.selectedUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersByRoleProvider(role));

    return usersAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Erreur: $e"),
      data: (users) {
        return DropdownButtonFormField<String>(
          value: selectedUserId?.isEmpty ?? true ? null : selectedUserId,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: label),
          items:
              users.map((user) {
                return DropdownMenuItem(
                  value: user.id,
                  child: Text('${user.name} (${user.instanceId})'),
                );
              }).toList(),
        );
      },
    );
  }
}
