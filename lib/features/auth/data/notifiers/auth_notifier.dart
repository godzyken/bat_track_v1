import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_state_provider.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(Ref ref) {
    ref.listen<User?>(authStateProvider, (previous, next) => notifyListeners());
  }
}

final authNotifierProvider = Provider<AuthNotifier>((ref) => AuthNotifier(ref));
