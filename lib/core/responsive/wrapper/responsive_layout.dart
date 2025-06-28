import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ScreenSize { mobile, tablet, desktop }

enum ScreenOrientation { portrait, landscape }

final screenSizeProvider = StateProvider<ScreenSize>(
  (ref) => ScreenSize.mobile,
);
final screenOrientationProvider = StateProvider<ScreenOrientation>(
  (ref) => ScreenOrientation.portrait,
);

class ResponsiveInfo {
  final ScreenSize screenSize;
  final ScreenOrientation orientation;

  const ResponsiveInfo(this.screenSize, this.orientation);

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  bool get isPortrait => orientation == ScreenOrientation.portrait;
  bool get isLandscape => orientation == ScreenOrientation.landscape;
}

class ResponsiveObserver extends ConsumerStatefulWidget {
  final Widget child;
  const ResponsiveObserver({required this.child, super.key});

  @override
  ConsumerState<ResponsiveObserver> createState() => _ResponsiveObserverState();
}

class _ResponsiveObserverState extends ConsumerState<ResponsiveObserver> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mq = MediaQuery.of(context);
      final width = mq.size.width;

      final screenSize =
          width < 600
              ? ScreenSize.mobile
              : width < 1024
              ? ScreenSize.tablet
              : ScreenSize.desktop;

      final screenOrientation =
          mq.orientation == Orientation.portrait
              ? ScreenOrientation.portrait
              : ScreenOrientation.landscape;

      ref.read(screenSizeProvider.notifier).state = screenSize;
      ref.read(screenOrientationProvider.notifier).state = screenOrientation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AutoResponsiveLayout extends ConsumerWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  const AutoResponsiveLayout({required this.builder, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final orientation = ref.watch(screenOrientationProvider);

    return builder(context, ResponsiveInfo(screenSize, orientation));
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveInfo responsiveInfo(WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final orientation = ref.watch(screenOrientationProvider);
    return ResponsiveInfo(screenSize, orientation);
  }
}

extension ResponsiveContextStatic on BuildContext {
  ResponsiveInfo get responsiveInfoStatic {
    final container = ProviderScope.containerOf(this);
    final screenSize = container.read(screenSizeProvider);
    final orientation = container.read(screenOrientationProvider);
    return ResponsiveInfo(screenSize, orientation);
  }
}
