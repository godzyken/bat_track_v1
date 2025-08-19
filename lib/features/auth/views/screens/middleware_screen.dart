import 'package:bat_track_v1/features/auth/views/screens/unauthorized_screen.dart';
import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/base/access_policy_interface.dart';
import '../../data/providers/auth_state_provider.dart';

class RoleGuard extends ConsumerWidget {
  final WidgetBuilder builder;
  final AccessPolicy policy;
  final String permission; // ex: access, edit, delete, create
  final dynamic entity;
  final Widget fallback;

  const RoleGuard({
    super.key,
    required this.builder,
    required this.policy,
    this.entity,
    this.permission = 'access',
    this.fallback = const UnauthorizedScreen(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return fallback;
        debugPrint("✅ middleware = data : ${user.email} / role: ${user.role}");

        final role = user.role;
        final ok = switch (permission) {
          'access' => policy.canAccess(role),
          'edit' => policy.canEdit(role),
          'delete' => policy.canDelete(role),
          'create' => policy.canCreate(role),
          _ => false,
        };

        return ok ? builder(context) : fallback;
      },
      loading: () => const LoadingApp(),
      error: (_, _) => const UnauthorizedScreen(),
    );
  }
}
