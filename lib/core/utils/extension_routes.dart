import 'package:go_router/go_router.dart';

extension GoRouterStateX on GoRouterState {
  bool get isLoggingIn =>
      matchedLocation == '/login' ||
      matchedLocation == '/register' ||
      matchedLocation == '/';
}
