
import '../responsive/wrapper/responsive_layout.dart';

extension ScreenSizeX on ScreenSize {
  bool get isMobile => this == ScreenSize.mobile;
  bool get isTablet => this == ScreenSize.tablet;
  bool get isDesktop => this == ScreenSize.desktop;
}

extension ScreenOrientationX on ScreenOrientation {
  bool get isPortrait => this == ScreenOrientation.portrait;
  bool get isLandscape => this == ScreenOrientation.landscape;
}
