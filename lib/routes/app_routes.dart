import 'package:bat_track_v1/features/dolibarr/views/screens/dolibarr_explorer_screen.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:bat_track_v1/models/views/screens/entity_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/models/index_model_extention.dart';
import '../data/remote/providers/dolibarr_instance_provider.dart';
import '../features/about/views/screens/about_screen.dart';
import '../features/auth/views/screens/login_screen.dart';
import '../features/chantier/views/screens/chantier_detail_loader.dart';
import '../features/chantier/views/screens/chantier_etape_detail_screen.dart';
import '../features/chantier/views/screens/chantier_etapes_screen.dart';
import '../features/chantier/views/screens/chantiers_screen.dart';
import '../features/client/views/screens/clients_screen.dart';
import '../features/dashboard/views/screens/dashboard_screen.dart';
import '../features/dolibarr/views/screens/dolibarr_import_client_screen.dart';
import '../features/home/views/screens/home_screen.dart';
import '../features/home/views/screens/pick_instance_screen.dart';
import '../features/intervention/views/screens/interventions_screen.dart';
import '../features/technicien/views/screens/technitiens_screen.dart';
import '../models/data/state_wrapper/wrappers.dart';
import '../models/notifiers/sync_entity_notifier.dart';
import '../providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final hasInstance = ref.watch(selectedInstanceProvider) != null;
  return GoRouter(
    initialLocation: '/',
    //refreshListenable: GoRouterRefreshStream(authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = authState;
      final isLoggingIn = state.uri.path == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      final isRoot = state.uri.path == '/';

      if (isRoot) {
        return hasInstance ? '/home' : '/pick-instance';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/pick-instance',
        builder: (context, state) => const PickInstanceScreen(),
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

              return EntityDetailScreen<Client>(
                id: id,
                title: 'Détail client',
                builder: (
                  BuildContext context,
                  Client client,
                  SyncEntityNotifier<Client> notifier,
                  SyncedState<Client> state,
                ) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom : ${client.nom}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Email : ${client.email}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final updated = client.copyWithId(id);
                            notifier.update(updated);
                          },
                          child: const Text('Modifier email'),
                        ),
                        if (state.isSyncing)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                  );
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
              return EntityDetailScreen<Technicien>(
                id: id,
                title: 'Détail technicien',
                builder: (
                  BuildContext context,
                  Technicien technicien,
                  SyncEntityNotifier<Technicien> notifier,
                  SyncedState<Technicien> state,
                ) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nom : ${technicien.nom}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Email : ${technicien.email}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final updated = technicien.copyWithId(id);
                            notifier.update(updated);
                          },
                          child: const Text('Modifier email'),
                        ),
                        if (state.isSyncing)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                  );
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
              final Chantier? passedChantier = state.extra as Chantier?;
              final chantierId = state.pathParameters['id']!;
              return ChantierDetailLoader(
                chantierId: chantierId,
                initialData: passedChantier,
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
              final id = state.pathParameters['id']!;
              return EntityDetailScreen<Intervention>(
                id: id,
                title: 'Détail intervention',
                builder: (
                  BuildContext context,
                  Intervention intervention,
                  SyncEntityNotifier<Intervention> notifier,
                  SyncedState<Intervention> state,
                ) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Titre : ${intervention.titre}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Commentaire id : ${intervention.commentaire ?? "non renseigné"}',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final updated = intervention.copyWithId(id);
                            notifier.update(updated);
                          },
                          child: const Text('Modifier commentaire'),
                        ),
                        if (state.isSyncing)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/import-dolibarr',
        builder: (context, state) => const DolibarrImportScreen(),
      ),
      GoRoute(
        path: '/explorer',
        builder: (context, state) => DolibarrExplorerScreen(),
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
