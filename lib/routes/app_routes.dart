import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/features/home/views/screens/home_screen.dart';
import 'package:bat_track_v1/features/projet/views/screens/project_list_screen.dart';
import 'package:bat_track_v1/features/technicien/views/screens/technicien_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/models/base/access_policy_interface.dart';
import '../features/auth/data/notifiers/auth_notifier.dart';
import '../features/auth/data/providers/auth_state_provider.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/auth/views/screens/register_screen.dart';
import '../features/auth/views/widgets/access_shell.dart';
import '../features/chantier/views/screens/chantier_extensions_screens.dart';
import '../features/documents/views/screens/factures_screen.dart';
import '../features/projet/views/screens/projet_detail_screen.dart';
import '../features/technicien/views/screens/technitiens_screen.dart';
import '../models/services/navigator_key_service.dart';
import '../models/views/screens/exeception_screens.dart';
import '../providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterRefreshNotifierProvider);
  final appUserAsync = ref.watch(appUserProvider);
  final policy = MultiRolePolicy();

  return GoRouter(
    navigatorKey: ref.read(navigatorKeyProvider),
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // 1. AppUser est en train d'être chargé
      if (appUserAsync.isLoading || appUserAsync.hasError) {
        return null; // On ne redirige pas encore
      }

      final appUser = appUserAsync.value;
      final isLoggedIn = appUser != null;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isOnLogin ? null : '/login';
      }

      return '/home';
    },
    routes: [
      ShellRoute(
        builder:
            (context, state, child) =>
                AccessShell(policy: policy, child: child),
        routes: [
          GoRoute(path: '/loading', builder: (_, _) => const LoadingApp()),
          GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
          GoRoute(
            path: '/error',
            builder:
                (_, _) => const ErrorApp(message: 'Erreur d\'authentification'),
          ),
          GoRoute(
            path: '/chantiers',
            builder: (context, state) => const ChantiersScreen(),
            routes: [
              GoRoute(
                path: ':chantierId',
                builder: (context, state) {
                  final chantier = state.extra as Chantier;
                  return ChantierDetailScreen(chantier: chantier);
                },
                routes: [
                  GoRoute(
                    path: '/etape',
                    builder: (context, state) {
                      final chantierId =
                          state.uri.queryParameters['chantierId'] ?? '';
                      return ChantierEtapesScreen(chantierId: chantierId);
                    },
                    routes: [
                      GoRoute(
                        path: ':etapeId',
                        builder: (context, state) {
                          final chantierId =
                              state.uri.queryParameters['chantierId'] ?? '';
                          final etapeId =
                              state.uri.queryParameters['etapeId'] ?? '';
                          return ChantierEtapeDetailScreen(
                            chantierId: chantierId,
                            etapeId: etapeId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: '/pieces',
                            builder: (context, state) {
                              final chantierId =
                                  state.uri.queryParameters['chantierId'] ?? '';
                              return ChantierPiecesScreen(
                                chantierId: chantierId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/techniciens',
            builder: (context, state) => const TechniciensScreen(),
            routes: [
              GoRoute(
                path: ':technicienId',
                builder: (context, state) {
                  final technicienId =
                      state.uri.queryParameters['technicienId'] ?? '';
                  return TechnicienDetailScreen(technicienId: technicienId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/documents',
            builder: (context, state) => const FacturesScreen(),
            routes: [],
          ),
          GoRoute(
            path: '/projets',
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: '/edit-projet',
                builder: (context, state) {
                  final currentuser = state.pathParameters['id'] as AppUser;
                  final projet = state.pathParameters['Projet'] as Projet;
                  return ProjectDetailScreen(
                    projet: projet,
                    currentUser: currentuser,
                  );
                },
                routes: [],
              ),
            ],
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
