import 'package:bat_track_v1/features/chantier/controllers/providers/chantier_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/wrapper/responsive_layout.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_content.dart';
import '../widgets/side_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Widget layout;
  late ScreenSize screenSize;

  @override
  void initState() {
    super.initState();
    detectScreenSizeOrientation();

    Future.microtask(() async {
      try {
        await ref.read(syncAllProvider).call();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la synchronisation')),
        );
      }
    });
  }

  void detectScreenSizeOrientation() {
    screenSize = ref.watch(screenSizeProvider);
    switch (screenSize) {
      case ScreenSize.desktop:
        layout = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 1, child: SideMenu()),
            const Expanded(flex: 3, child: HomeContent()),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      drawer: screenSize == ScreenSize.mobile ? const AppDrawer() : null,
      body: layout,
    );
  }
}
