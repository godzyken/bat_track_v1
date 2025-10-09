import 'package:bat_track_v1/data/local/models/utilisateurs/user.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/routes/app_shell_route/frame_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../../../models/views/screens/exeception_screens.dart';
import '../../data/notifiers/auth_notifier.dart';
import '../screens/login_screen.dart';
import '../screens/unauthorized_screen.dart';

class AccessShell extends ConsumerWidget {
  final Widget child;
  final MultiRolePolicy policy;
  final GoRouterState state;
  const AccessShell({
    super.key,
    required this.child,
    required this.policy,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(userStatusProvider);
    final authState = ref.watch(authNotifierProvider);

    return switch (status) {
      UserStatus.guest => const LoginScreen(),
      UserStatus.authenticated => const LoadingApp(),
      UserStatus.loaded => authState.when(
        data: (user) {
          if (user == null) {
            return Stack(
              children: [
                const Center(child: Text('Pas encore connecté')),
                const LoginScreen(),
              ],
            );
          }
          debugPrint(
            "✅ accessShell = data : ${user.email} / role: ${user.role}",
          );

          final location = state.uri.toString();
          debugPrint("🔍 Navigation vers $location avec rôle ${user.role}");

          if (!policy.canAccess(user.role)) {
            return const UnauthorizedScreen();
          }

          return MainLayout(child: child); // Layout commun avec menu & app bar
        },
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (_, _) => const UnauthorizedScreen(),
      ),
    };
  }
}
