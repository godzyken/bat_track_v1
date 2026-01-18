import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';
import '../providers/auth_notifier_provider.dart';

/// Notifier pour rafraîchir le GoRouter quand auth change
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this.ref) {
    ref.listen<AsyncValue<AppUser?>>(authNotifierProvider, (previous, next) {
      if (previous?.value?.uid != next.value?.uid) {
        notifyListeners();
      }
    });
  }

  final Ref ref;
}
