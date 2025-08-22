import 'package:bat_track_v1/features/chantier/controllers/providers/chantier_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/wrapper/responsive_layout.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_content.dart';
import '../widgets/side_menu.dart';

/// HomeScreen simplifié, responsive
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Synchronise les providers (par ex. fetch des chantiers)
  Future<void> _syncProviders(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(syncAllProvider).call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la synchronisation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accès rapide aux infos responsive
    final info = context.responsiveInfo(ref);

    // Lance la synchronisation au build initial
    Future.microtask(() => _syncProviders(context, ref));

    // Layout responsive
    Widget layout;
    switch (info.screenSize) {
      case ScreenSize.desktop:
        layout = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(flex: 1, child: SideMenu()),
            Expanded(flex: 3, child: HomeContent()),
          ],
        );
        break;
      case ScreenSize.tablet:
        layout = Column(
          children: const [SideMenu(), Expanded(child: HomeContent())],
        );
        break;
      case ScreenSize.mobile:
        layout = const HomeContent();
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      drawer: info.isMobile ? const AppDrawer() : null,
      body: layout,
    );
  }
}
