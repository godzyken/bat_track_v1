import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

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
                'Construction 4.0',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildNavItem(context, Icons.home, 'Accueil', '/'),
            _buildNavItem(context, Icons.people, 'Clients', '/clients'),
            _buildNavItem(
              context,
              Icons.engineering,
              'Techniciens',
              '/techniciens',
            ),
            _buildNavItem(
              context,
              Icons.construction,
              'Chantiers',
              '/chantiers',
            ),
            _buildNavItem(
              context,
              Icons.build_circle,
              'Interventions',
              '/interventions',
            ),
            const Divider(),
            _buildNavItem(context, Icons.info_outline, 'À propos', '/about'),
          ],
        ),
      ),
    );
  }

  ListTile _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop(); // Ferme le drawer après navigation
      },
    );
  }
}
