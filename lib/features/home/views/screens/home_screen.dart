import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/wrapper/responsive_layout.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_content.dart';
import '../widgets/side_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    Widget layout;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      drawer: screenSize == ScreenSize.mobile ? const AppDrawer() : null,
      body: layout,
    );
  }
}
