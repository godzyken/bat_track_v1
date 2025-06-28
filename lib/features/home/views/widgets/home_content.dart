import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/wrapper/responsive_layout.dart';
import '../../../dashboard/views/widgets/dashboard_preview_card.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = ref.watch(screenSizeProvider) == ScreenSize.desktop;
    final textTheme = Theme.of(context).textTheme;

    final welcomeSection = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.home_work, size: 72, color: Colors.indigo.shade400),
        const SizedBox(height: 20),
        Text(
          'Bienvenue dans Construction 4.0',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Gérez vos clients, techniciens, chantiers et interventions efficacement.',
          style: textTheme.bodyLarge,
          textAlign: isWide ? TextAlign.left : TextAlign.center,
        ),
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child:
            isWide
                ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Partie texte
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: welcomeSection,
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Partie carte
                      const Expanded(child: DashboardPreviewCard()),
                    ],
                  ),
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    welcomeSection,
                    const SizedBox(height: 20),
                    const DashboardPreviewCard(),
                  ],
                ),
      ),
    );
  }
}
