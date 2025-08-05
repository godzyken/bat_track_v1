import 'package:bat_track_v1/data/local/models/chantiers/chantier.dart';
import 'package:bat_track_v1/features/auth/data/notifiers/auth_notifier.dart';
import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:bat_track_v1/features/auth/views/screens/register_screen.dart';
import 'package:bat_track_v1/features/chantier/views/screens/chantiers_screen.dart';
import 'package:bat_track_v1/features/documents/views/screens/factures_screen.dart';
import 'package:bat_track_v1/models/views/screens/exeception_screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/views/screens/login_screen.dart';
import '../features/chantier/views/screens/chantier_details_screen.dart';
import '../features/chantier/views/screens/chantier_pieces_screen.dart';
import '../features/technicien/views/screens/technitiens_screen.dart';
import '../models/services/navigator_key_service.dart';
import '../providers/auth_provider.dart';
import 'app_shell_route/frame_layout.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  final appUserAsync = ref.watch(appUserProvider);
  //final role = ref.watch(userProfileProvider).value;

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/loading',
    debugLogDiagnostics: true,
    navigatorKey: ref.read(navigatorKeyProvider),
    redirect: (context, state) {
      final appUser = appUserAsync.asData?.value;
      final isLoggedIn = appUser != null;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnLoading = state.matchedLocation == '/loading';

      if (!isLoggedIn) {
        return isOnLogin ? null : '/login';
      }

      if (isOnLogin || isOnLoading) {
        switch (appUser.role) {
          case 'Administrateur':
            return '/admin/dashboard';
          case 'Intervenant':
            return '/tech/dashboard';
          case 'Client':
            return '/client/dashboard';
          default:
            return '/unauthorized';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/loading', builder: (_, _) => const LoadingApp()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/error',
        builder:
            (context, state) =>
                const ErrorApp(message: 'Erreur d\'authentification'),
      ),

      /// ----------------------------
      /// ADMIN SHELL ROUTE
      /// ----------------------------
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, _) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, _) => const AdminUserManagementScreen(),
          ),
          GoRoute(
            path: '/admin/chantiers',
            builder: (context, state) => const ChantiersScreen(),
            routes: [
              GoRoute(
                path: ':chantierId',
                builder: (context, state) {
                  final chantier = state.extra as Chantier;
                  return ChantierDetailScreen(chantier: chantier);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/techniciens',
            builder: (context, state) => const TechniciensScreen(),
          ),
          GoRoute(
            path: '/admin/pieces',
            builder:
                (context, state) => ChantierPiecesScreen(
                  chantierId: state.pathParameters['id']!,
                ),
          ),
          GoRoute(
            path: '/admin/factures',
            builder: (context, state) => const FacturesScreen(),
          ),
        ],
      ),

      /// ----------------------------
      /// TECH SHELL ROUTE
      /// ----------------------------
      ShellRoute(
        builder: (context, state, child) => TechLayout(child: child),
        routes: [
          GoRoute(
            path: '/tech/dashboard',
            builder: (_, _) => const TechDashboardScreen(),
          ),
          GoRoute(
            path: '/tech/interventions',
            builder: (_, _) => const TechInterventionScreen(),
          ),
          GoRoute(
            path: '/tech/chantiers',
            builder: (context, state) => const ChantiersScreen(),
            routes: [
              GoRoute(
                path: ':chantierId',
                name: 'chantier-detail',
                builder: (context, state) {
                  final chantier = state.extra as Chantier;
                  final isClient =
                      state.uri.queryParameters['isClient'] == 'true';
                  final isTechnicien =
                      state.uri.queryParameters['isTechnicien'] == 'true';
                  final userId = state.uri.queryParameters['userId'];
                  return ChantierDetailScreen(
                    chantier: chantier,
                    isClient: isClient,
                    isTechnicien: isTechnicien,
                    userId: userId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/tech/pieces',
            builder:
                (context, state) => const ChantierPiecesScreen(chantierId: ''),
          ),
        ],
      ),

      /// ----------------------------
      /// CLIENT SHELL ROUTE
      /// ----------------------------
      ShellRoute(
        builder: (context, state, child) => ClientLayout(child: child),
        routes: [
          GoRoute(
            path: '/client/dashboard',
            builder: (_, _) => const ClientDashboardScreen(),
          ),
          GoRoute(
            path: '/client/chantiers',
            builder: (_, _) => const ClientChantiersScreen(),
          ),
        ],
      ),
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
