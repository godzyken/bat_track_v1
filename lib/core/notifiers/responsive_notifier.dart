import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../responsive/wrapper/responsive_layout.dart';

class ScreenSizeNotifier extends Notifier<ScreenSize> {
  @override
  ScreenSize build() => ScreenSize.mobile; // valeur par défaut sûre

  void update(ScreenSize size) {
    if (state != size) state = size;
  }
}

class ScreenOrientationNotifier extends Notifier<ScreenOrientation> {
  @override
  ScreenOrientation build() => ScreenOrientation.portrait;

  void update(ScreenOrientation orientation) {
    if (state != orientation) state = orientation;
  }
}

class ResponsiveNotifier extends Notifier<ResponsiveInfo> {
  @override
  ResponsiveInfo build() =>
      ResponsiveInfo(ScreenSize.mobile, ScreenOrientation.portrait);

  void update(ScreenSize size, ScreenOrientation orientation) {
    if (state.screenSize != size || state.orientation != orientation) {
      state = ResponsiveInfo(size, orientation);
    }
  }

  bool get isPortrait => state.orientation == ScreenOrientation.portrait;
  bool get isLandscape => state.orientation == ScreenOrientation.landscape;

  bool get isMobile => state.screenSize == ScreenSize.mobile;
  bool get isTablet => state.screenSize == ScreenSize.tablet;
  bool get isDesktop => state.screenSize == ScreenSize.desktop;
}
