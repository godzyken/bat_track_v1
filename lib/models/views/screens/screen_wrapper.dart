import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenWrapper extends ConsumerWidget {
  final String? title;
  final Widget child;
  final bool showAppBar;
  final bool scrollable;

  const ScreenWrapper({
    super.key,
    this.title,
    required this.child,
    this.showAppBar = true,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsiveInfo = context.responsiveInfo(ref);

    final padding =
        responsiveInfo.isMobile
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    final bodyContent =
        scrollable
            ? SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(padding: padding, child: child),
            )
            : Padding(padding: padding, child: child);

    return Scaffold(
      appBar:
          showAppBar
              ? AppBar(
                title: Text(title ?? ''),
                centerTitle: true,
                elevation: 2,
              )
              : null,
      body: SafeArea(child: bodyContent),
    );
  }
}
