import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'BatTrack Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            _navItem(context, 'Accueil', '/', Icons.home),
            _navItem(context, 'Clients', '/clients', Icons.people),
            _navItem(context, 'Techniciens', '/techniciens', Icons.settings),
            _navItem(context, 'Chantiers', '/chantiers', Icons.work),
            _navItem(context, 'Interventions', '/interventions', Icons.build),
            const Divider(),
            _navItem(context, 'À propos', '/about', Icons.info),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text('Voulez-vous vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Déconnexion'),
                          ),
                        ],
                      ),
                );

                if (confirm == true && context.mounted) {
                  ref.read(authProvider.notifier).state = false;
                  context.go('/login'); // redirection après déconnexion
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile _navItem(
    BuildContext context,
    String title,
    String path, [
    IconData? icon,
  ]) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      onTap: () => context.go(path),
    );
  }
}
