import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/responsive_provider.dart';

class ResponsiveWrapper extends ConsumerWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final screenSize =
        width >= 1024
            ? ScreenSize.desktop
            : width >= 600
            ? ScreenSize.tablet
            : ScreenSize.mobile;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenSizeProvider.notifier).state = screenSize;
    });

    return child;
  }
}
