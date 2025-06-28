import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/views/screens/about_screen.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/chantier/views/screens/chantiers_screen.dart';
import '../features/client/views/screens/clients_screen.dart';
import '../features/dashboard/views/screens/dashboard_screen.dart';
import '../features/home/views/screens/home_screen.dart';
import '../features/intervention/views/screens/interventions_screen.dart';
import '../features/technicien/views/screens/technitien_screen.dart';
import '../providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    //refreshListenable: GoRouterRefreshStream(authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = authState;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/clients',
        builder: (context, state) => const ClientsScreen(),
      ),
      GoRoute(
        path: '/techniciens',
        builder: (context, state) => const TechniciensScreen(),
      ),
      GoRoute(
        path: '/chantiers',
        builder: (context, state) => const ChantiersScreen(),
      ),
      GoRoute(
        path: '/interventions',
        builder: (context, state) => const InterventionsScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  );
});

// Exposition de l'état d'auth global
bool get authState => _authRef?.read(authProvider) ?? false;
late WidgetRef? _authRef;

final authStateChanges = Stream<void>.periodic(
  const Duration(milliseconds: 300),
);

void setAuthRef(WidgetRef ref) {
  _authRef = ref;
}
