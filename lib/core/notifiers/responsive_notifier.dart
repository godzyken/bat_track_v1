import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../responsive/wrapper/responsive_layout.dart';

class ScreenSizeNotifier extends Notifier<ScreenSize> {
  @override
  ScreenSize build() => ScreenSize.mobile; // valeur par défaut sûre

  void update(double width) {
    final next = width < 600
        ? ScreenSize.mobile
        : width < 1024
        ? ScreenSize.tablet
        : ScreenSize.desktop;

    if (state != next) state = next;
  }
}

class ScreenOrientationNotifier extends Notifier<ScreenOrientation> {
  @override
  ScreenOrientation build() => ScreenOrientation.portrait;

  void update(Orientation orientation) {
    final next = orientation == Orientation.portrait
        ? ScreenOrientation.portrait
        : ScreenOrientation.landscape;

    if (state != next) state = next;
  }
}
