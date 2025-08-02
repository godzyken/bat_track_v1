import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/user.dart';
import '../../../../models/views/widgets/entity_form.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Utilisateurs")),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Erreur: $e")),
        data:
            (users) => ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text("${user.email} – ${user.role.name}"),
                  trailing: DropdownButton<String>(
                    value: user.role.name,
                    onChanged: (newRole) async {
                      if (newRole == null) return;
                      await ref
                          .read(firestoreProvider)
                          .collection('users')
                          .doc(user.id)
                          .update({'rôle': newRole});
                    },
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'tech', child: Text('Tech')),
                      DropdownMenuItem(value: 'client', child: Text('Client')),
                    ],
                  ),
                );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (_) => EntityForm<UserModel>(
                  onSubmit: (newUser) async {
                    await ref
                        .read(firestoreProvider)
                        .collection('users')
                        .doc(newUser.id)
                        .set(newUser.toJson());
                  },
                  fromJson: UserModel.fromJson,
                  createEmpty: () => UserModel.mock(),
                ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
