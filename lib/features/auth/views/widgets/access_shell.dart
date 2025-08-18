import 'package:bat_track_v1/routes/app_shell_route/frame_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../data/providers/auth_state_provider.dart';
import '../screens/login_screen.dart';
import '../screens/unauthorized_screen.dart';

class AccessShell extends ConsumerWidget {
  final Widget child;
  final MultiRolePolicy policy;
  const AccessShell({super.key, required this.child, required this.policy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState.value;
    if (userId == null) {
      return Stack(
        children: [
          const Center(child: Text('Pas encore connecté')),
          const LoginScreen(),
        ],
      );
    }

    return authState.when(
      data: (user) {
        final location = GoRouterState.of(context).uri.toString();
        debugPrint("🔍 Navigation vers $location avec rôle ${user?.role}");

        if (!policy.canAccess(user!.role)) {
          return const UnauthorizedScreen();
        }

        return MainLayout(child: child); // Layout commun avec menu & app bar
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const UnauthorizedScreen(),
    );
  }
}
