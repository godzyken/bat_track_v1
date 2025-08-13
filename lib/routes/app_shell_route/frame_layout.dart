// Layouts communs pour les rôles

import 'package:bat_track_v1/features/home/views/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

// ---------------- MAINLAYOUT ----------------
// Layout commun
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('batTrack')),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
