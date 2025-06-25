import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum pour les types d'écran
enum ScreenSize { mobile, tablet, desktop }

/// Provider pour stocker dynamiquement la taille d’écran
final screenSizeProvider = StateProvider<ScreenSize>((ref) {
  return ScreenSize.mobile; // Valeur par défaut
});
