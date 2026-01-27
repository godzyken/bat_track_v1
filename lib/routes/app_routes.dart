import 'dart:developer' as developer;

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
import '../features/auth/data/providers/auth_notifier_provider.dart';
import '../features/auth/data/providers/go_route_notifier_provider.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/auth/views/screens/register_screen.dart';
import '../features/auth/views/screens/user_profile_screen.dart';
import '../features/auth/views/widgets/access_shell.dart';
import '../features/chantier/views/screens/chantier_extensions_screens.dart';
import '../features/documents/views/screens/facture_detail_screen.dart';
import '../features/documents/views/screens/factures_screen.dart';
import '../features/intervention/views/screens/interventions_screen.dart';
import '../features/projet/views/screens/projet_detail_screen.dart';
import '../features/technicien/views/screens/technitiens_screen.dart';
import '../models/services/navigator_key_service.dart';
import '../models/views/screens/exeception_screens.dart';
import '../providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(goRouterRefreshNotifierProvider);
  final policy = MultiRolePolicy();

  return GoRouter(
    navigatorKey: ref.read(navigatorKeyProvider),
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final status = ref.read(userStatusProvider);
      final location = state.matchedLocation;

      // ✅ Routes publiques toujours accessibles
      final publicRoutes = ['/login', '/register', '/loading', '/error'];
      if (publicRoutes.contains(location)) {
        return null;
      }

      switch (status) {
        case UserStatus.guest:
          developer.log('🔒 Guest détecté → redirection vers /login');
          return '/login';

        case UserStatus.authenticated:
          if (location != '/loading') {
            developer.log('⏳ Chargement profil → /loading');
            return '/loading';
          }
          return null;
        case UserStatus.loaded:
          // ✅ Utilisateur chargé
          final userAsync = ref.read(currentUserProvider);

          if (userAsync.hasError) {
            developer.log('❌ Erreur chargement user → /error');
            return '/error';
          }

          final appUser = userAsync.value;
          if (appUser == null) {
            developer.log('⚠️ User null malgré status loaded → /login');
            return '/login';
          }

          // ✅ Si sur page de loading, rediriger selon le rôle
          if (location == '/loading') {
            final role = appUser.role.toLowerCase();
            developer.log(
              '✅ User chargé (${appUser.email}) → redirection selon rôle: $role',
            );

            return switch (role) {
              'admin' || 'superutilisateur' => '/dashboard',
              'technicien' => '/techniciens',
              'client' || 'chefdeprojet' => '/clients',
              _ => '/home',
            };
          }

          // ✅ Vérification des permissions
          if (!policy.canAccess(appUser.role)) {
            developer.log('🚫 Accès refusé pour ${appUser.role} → /error');
            return '/error';
          }

          return null;
      }
    },
    routes: [
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
        path: '/error',
        builder: (_, _) =>
            const ErrorApp(message: 'Erreur d\'authentification'),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AccessShell(policy: policy, state: state, child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'Home',
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'Profile',
            builder: (_, _) => const UserProfileScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            name: 'Dashboard',
            builder: (_, _) => const DashboardScreen(),
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
                  return ChantierDetailScreen(chantierId: chantier.id);
                },
                routes: [
                  GoRoute(
                    path: 'etapes',
                    name: 'Etapes',
                    builder: (context, state) {
                      final chantierId =
                          state.pathParameters['chantierId'] ?? '';
                      return ChantierEtapesScreen(chantierId: chantierId);
                    },
                    routes: [
                      GoRoute(
                        path: ':etapeId',
                        builder: (context, state) {
                          final chantierId =
                              state.pathParameters['chantierId'] ?? '';
                          final etapeId = state.pathParameters['etapeId'] ?? '';
                          return ChantierEtapeDetailScreen(
                            chantierId: chantierId,
                            etapeId: etapeId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'pieces',
                            name: 'Pieces',
                            builder: (context, state) {
                              final chantierId =
                                  state.pathParameters['chantierId'] ?? '';
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
                    path: "interventions/:statut",
                    builder: (context, state) {
                      final chantierId = state.pathParameters["chantierId"]!;
                      final statut = state.pathParameters["statut"]!;
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
                      state.pathParameters['technicienId'] ?? '';
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
                  final clientId = state.pathParameters['clientId'] ?? '';
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
                  final currentUser = ref.read(authNotifierProvider).value;
                  if (currentUser == null) {
                    return const ErrorApp(message: 'Utilisateur non connecté');
                  }
                  final documentId = currentUser.id;

                  final projetId = state.pathParameters['ProjetId'] as Projet;
                  return FactureDetailScreen(
                    userId: documentId,
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
                  final currentUser = ref.read(authNotifierProvider).value;
                  if (currentUser == null) {
                    return const ErrorApp(message: 'Utilisateur non connecté');
                  }
                  final documentId = currentUser.id;

                  final projetId = state.pathParameters['ProjetId'] as Projet;
                  return FactureDetailScreen(
                    userId: documentId,
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
                  final projet = state.extra as Projet?;

                  if (projet == null) {
                    return const ErrorApp(message: 'Projet introuvable');
                  }

                  final currentUser = ref.read(currentUserProvider).value;
                  if (currentUser == null) {
                    return const ErrorApp(message: 'Utilisateur non connecté');
                  }

                  return ProjectDetailScreen(
                    projet: projet,
                    currentUser: currentUser,
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
