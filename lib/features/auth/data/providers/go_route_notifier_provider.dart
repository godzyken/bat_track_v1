import 'package:bat_track_v1/features/auth/data/notifiers/go_route_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final goRouterRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((
  ref,
) {
  return GoRouterRefreshNotifier(ref);
});
