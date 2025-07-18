import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsiveCardLayout extends ConsumerWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveCardLayout({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = context.responsiveInfo(ref);

    if (info.isDesktop || (info.isTablet && info.isLandscape)) {
      // Affichage en grille fluide avec centrage et scroll si besoin
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(spacing),
            child: Center(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children:
                    children.map((child) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 300,
                          maxWidth: 480,
                        ),
                        child: child,
                      );
                    }).toList(),
              ),
            ),
          );
        },
      );
    } else {
      // Affichage vertical (mobile ou portrait)
      return ListView.separated(
        padding: EdgeInsets.all(spacing),
        itemCount: children.length,
        separatorBuilder: (_, _) => SizedBox(height: spacing),
        itemBuilder: (context, index) => children[index],
      );
    }
  }
}

class ResponsiveCard extends ConsumerWidget {
  final Widget child;
  final String? title;
  final Widget? action;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          // ✅ ajout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || action != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if (action != null) action!,
                  ],
                ),
              if (title != null || action != null) const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
