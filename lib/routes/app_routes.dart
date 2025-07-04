import 'package:bat_track_v1/features/chantier/views/screens/chantier_details_screen.dart';
import 'package:bat_track_v1/models/views/screens/entity_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/providers/hive_provider.dart';
import '../features/about/views/screens/about_screen.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/chantier/views/screens/chantier_etape_detail_screen.dart';
import '../features/chantier/views/screens/chantier_etapes_screen.dart';
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
        routes: [
          GoRoute(
            path: 'client/:id',
            name: 'client-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Consumer(
                builder: (context, ref, child) {
                  final client = ref.watch(clientProvider(id));
                  if (client == null) {
                    return Scaffold(body: Text('Client introuvable'));
                  }
                  return EntityDetailScreen(entity: client);
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/techniciens',
        builder: (context, state) => const TechniciensScreen(),
        routes: [
          GoRoute(
            path: 'technicien/:id',
            name: 'technicien-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Consumer(
                builder: (context, ref, child) {
                  final technicien = ref.watch(technicienProvider(id));
                  if (technicien == null) {
                    return Scaffold(body: Text('Technicien introuvable'));
                  }
                  return EntityDetailScreen(entity: technicien);
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/chantiers',
        builder: (context, state) => const ChantiersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'chantier-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Consumer(
                builder: (context, ref, child) {
                  final chantier = ref.watch(chantierProvider(id));
                  if (chantier == null) {
                    return const Scaffold(
                      body: Center(child: Text('Chantier introuvable')),
                    );
                  }
                  return ChantierDetailScreen(chantier: chantier);
                },
              );
            },
            routes: [
              // ✅ 1. Liste des étapes
              GoRoute(
                path: 'etapes',
                name: 'chantier-etapes',
                builder: (context, state) {
                  final chantierId = state.pathParameters['id']!;
                  return ChantierEtapesScreen(chantierId: chantierId);
                },
                routes: [
                  // ✅ 2. Détail d’une étape
                  GoRoute(
                    path: ':etapeId',
                    name: 'chantier-etape-detail',
                    builder: (context, state) {
                      final chantierId = state.pathParameters['id']!;
                      final etapeId = state.pathParameters['etapeId']!;
                      return ChantierEtapeDetailScreen(
                        chantierId: chantierId,
                        etapeId: etapeId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/interventions',
        builder: (context, state) => const InterventionsScreen(),
        routes: [
          GoRoute(
            path: 'intervention/:id',
            name: 'intervention-detail',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return Consumer(
                builder: (context, ref, child) {
                  final intervention = ref.watch(interventionProvider(id!));
                  if (intervention == null) {
                    return Scaffold(body: Text('Intervention introuvable'));
                  }
                  return EntityDetailScreen(entity: intervention);
                },
              );
            },
          ),
        ],
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
