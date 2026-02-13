import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/features/auth/views/screens/unauthorized_screen.dart';
import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/core/interface/projet.dart';

class RoleGuard extends ConsumerWidget {
  final WidgetBuilder builder;
  final IAccessible? policy;
  final String permission;
  final Widget fallback;

  const RoleGuard({
    super.key,
    required this.builder,
    required this.policy,
    this.permission = 'access',
    this.fallback = const UnauthorizedScreen(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return fallback;
        debugPrint("✅ middleware = data : ${user.email} / role: ${user.role}");

        final ok = switch (permission) {
          'access' => policy?.canAccess(user) ?? false,
          'edit' => policy?.canEdit(user) ?? false,
          'delete' => policy?.canDelete(user) ?? false,
          'create' => policy?.canCreate(user) ?? false,
          _ => false,
        };

        return ok ? builder(context) : fallback;
      },
      loading: () => const LoadingApp(),
      error: (_, _) => const UnauthorizedScreen(),
    );
  }
}
