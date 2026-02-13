import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/routes/app_shell_route/frame_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../models/views/screens/exeception_screens.dart';
import '../screens/login_screen.dart';
import '../screens/unauthorized_screen.dart';

class AccessShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;
  const AccessShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(userStatusProvider);
    final currentUser = ref.watch(currentUserProvider);

    return switch (status) {
      UserStatus.guest => const LoginScreen(),
      UserStatus.authenticated => const LoadingApp(),
      UserStatus.loaded => currentUser.when(
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

          // Vérification simple du rôle pour toutes les pages protégées
          final allowedRoles = [
            'admin',
            'superutilisateur',
            'technicien',
            'client',
            'chefdeprojet',
          ];
          if (!allowedRoles.contains(user.role.toLowerCase())) {
            return const UnauthorizedScreen();
          }

          // Ici tu peux vérifier l’accès sur une entité si `state.extra` est fourni
          if (state.extra is AccessControlMixin) {
            final entity = state.extra as AccessControlMixin;
            if (!entity.canRead(user)) {
              return const UnauthorizedScreen();
            }
          }

          return MainLayout(child: child); // Layout commun avec menu & app bar
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const UnauthorizedScreen(),
      ),
    };
  }
}
