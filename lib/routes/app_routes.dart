import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/features/client/views/screens/client_home_screen.dart';
import 'package:bat_track_v1/features/client/views/screens/clients_screen.dart';
import 'package:bat_track_v1/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:bat_track_v1/features/equipement/views/screens/equipement_list_screen.dart';
import 'package:bat_track_v1/features/home/views/screens/home_screen.dart';
import 'package:bat_track_v1/features/projet/views/screens/project_list_screen.dart';
import 'package:bat_track_v1/features/technicien/views/screens/technicien_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/models/base/access_policy_interface.dart';
import '../features/auth/data/notifiers/auth_notifier.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/auth/views/screens/register_screen.dart';
import '../features/auth/views/widgets/access_shell.dart';
import '../features/chantier/views/screens/chantier_extensions_screens.dart';
import '../features/documents/views/screens/factureDetailScreen.dart';
import '../features/documents/views/screens/factures_screen.dart';
import '../features/intervention/views/screens/interventions_screen.dart';
import '../features/projet/views/screens/projet_detail_screen.dart';
import '../features/technicien/views/screens/technitiens_screen.dart';
import '../models/services/navigator_key_service.dart';
import '../models/views/screens/exeception_screens.dart';
import '../providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterRefreshNotifierProvider);
  final appUserAsync = ref.watch(currentUserProvider);
  final policy = MultiRolePolicy();

  return GoRouter(
    navigatorKey: ref.read(navigatorKeyProvider),
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (appUserAsync.isLoading || appUserAsync.hasError) return null;

      final appUser = appUserAsync.value;
      final isLoggedIn = appUser != null;

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn) return loggingIn ? null : '/login';

      // Déjà connecté, on ne doit pas rester sur login/register
      if (loggingIn) {
        final role = UserRoleX.fromString(appUser.role);
        switch (role) {
          case UserRole.superUtilisateur:
            return '/admin/dashboard';
          case UserRole.technicien:
            return '/tech/dashboard';
          case UserRole.client:
          case UserRole.chefDeProjet:
            return '/client/dashboard';
        }
      }

      // Si déjà sur une route autorisée, ne rien changer
      return null;
    },
    routes: [
      ShellRoute(
        builder:
            (context, state, child) =>
                AccessShell(policy: policy, state: state, child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: '/loading',
            name: 'loading',
            builder: (_, _) => const LoadingApp(),
          ),
          GoRoute(
            path: '/login',
            name: 'Login',
            builder: (_, _) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            name: 'Register',
            builder: (_, _) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'Dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/error',
            builder:
                (_, _) => const ErrorApp(message: 'Erreur d\'authentification'),
          ),
          GoRoute(
            path: '/chantiers',
            name: 'Chantiers',
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
                    path: '/etapes',
                    name: 'Etapes',
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
                            name: 'Pieces',
                            builder: (context, state) {
                              final chantierId =
                                  state.uri.queryParameters['chantierId'] ?? '';
                              return ChantierPiecesScreen(
                                chantierId: chantierId,
                              );
                            },
                            /*   routes: [
                              GoRoute(
                                path: "/pieces/:pieceId",
                                builder: (context, state) {
                                  final chantierId =
                                      state.uri.queryParameters["chantierId"]!;
                                  final pieceId =
                                      state.uri.queryParameters["pieceId"]!;
                                  return PieceDetailScreen(
                                    chantierId: chantierId,
                                    pieceId: pieceId,
                                  );
                                },
                              ),
                            ],*/
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: "/chantier/:chantierId/interventions/:statut",
                    builder: (context, state) {
                      final chantierId =
                          state.uri.queryParameters["chantierId"]!;
                      final statut = state.uri.queryParameters["statut"]!;
                      return InterventionsScreen(
                        chantierId: chantierId,
                        statut: statut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/techniciens',
            name: 'Techniciens',
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
            path: '/clients',
            name: 'Clients',
            builder: (context, state) => const ClientsScreen(),
            routes: [
              GoRoute(
                path: ':clientId',
                builder: (context, state) {
                  final clientId = state.uri.queryParameters['clientId'] ?? '';
                  return ClientHomeScreen(clientId: clientId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/documents',
            name: 'Documents',
            builder: (context, state) => const FacturesScreen(),
            routes: [
              GoRoute(
                path: ':documentId',
                builder: (context, state) {
                  final currentuser = state.pathParameters['id'] as AppUser;
                  final projetId = state.pathParameters['ProjetId'] as Projet;
                  return FactureDetailScreen(
                    userId: currentuser.id,
                    projetId: projetId.id,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/equipements',
            name: 'Equipements',
            builder: (context, state) => const EquipementScreen(),
            routes: [
              GoRoute(
                path: ':equipementId',
                builder: (context, state) {
                  final currentuser = state.pathParameters['id'] as AppUser;
                  final projetId = state.pathParameters['ProjetId'] as Projet;
                  return FactureDetailScreen(
                    userId: currentuser.id,
                    projetId: projetId.id,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/projets',
            name: 'Projets',
            builder: (context, state) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: ':projetId',
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
