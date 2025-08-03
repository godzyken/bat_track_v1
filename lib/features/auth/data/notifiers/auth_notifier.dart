import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_state_provider.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
      if (previous?.value?.uid != next.value?.uid) {
        notifyListeners();
      }
    });
  }

  final Ref _ref;
}

final authNotifierProvider = Provider<AuthNotifier>((ref) => AuthNotifier(ref));
