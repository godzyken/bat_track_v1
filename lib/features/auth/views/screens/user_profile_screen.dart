import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../models/views/screens/exeception_screens.dart';
import '../../data/providers/current_user_provider.dart';
import '../../data/repository/auth_repository.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const LoadingApp(),
        error: (e, _) => ErrorApp(message: 'Erreur: $e'),
        data: (user) {
          if (user == null) {
            return const ErrorApp(message: 'Utilisateur non connecté');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    user.name!.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 48, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  user.name!,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                Chip(
                  label: Text(user.role.toUpperCase()),
                  backgroundColor: Colors.indigo.shade100,
                ),

                const SizedBox(height: 32),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(user.email!),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.business_outlined),
                        title: const Text('Entreprise'),
                        subtitle: Text(user.company!),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text('Membre depuis'),
                        subtitle: Text(
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implémenter l'édition du profil
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité en développement'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier mon profil'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
