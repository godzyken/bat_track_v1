// Layouts communs pour les rôles

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------- ADMIN LAYOUT ----------------
class AdminLayout extends StatelessWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👑 Admin')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu Admin')),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () => context.go('/admin/dashboard'),
            ),
            ListTile(
              title: const Text('Utilisateurs'),
              onTap: () => context.go('/admin/users'),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}

// ---------------- TECH LAYOUT ----------------
class TechLayout extends StatelessWidget {
  final Widget child;
  const TechLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛠️ Technicien')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu Tech')),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () => context.go('/tech/dashboard'),
            ),
            ListTile(
              title: const Text('Interventions'),
              onTap: () => context.go('/tech/interventions'),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}

// ---------------- CLIENT LAYOUT ----------------
class ClientLayout extends StatelessWidget {
  final Widget child;
  const ClientLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏢 Client')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu Client')),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () => context.go('/client/dashboard'),
            ),
            ListTile(
              title: const Text('Chantiers'),
              onTap: () => context.go('/client/chantiers'),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}

// ---------------- SCREENS EXEMPLE ----------------
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('👑 Admin Dashboard'));
  }
}

class AdminUserManagementScreen extends StatelessWidget {
  const AdminUserManagementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('👥 Gestion des utilisateurs'));
  }
}

class TechDashboardScreen extends StatelessWidget {
  const TechDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('🛠️ Dashboard technicien'));
  }
}

class TechInterventionScreen extends StatelessWidget {
  const TechInterventionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('📋 Liste des interventions'));
  }
}

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('🏢 Dashboard client'));
  }
}

class ClientChantiersScreen extends StatelessWidget {
  const ClientChantiersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('🏗️ Liste des chantiers'));
  }
}
