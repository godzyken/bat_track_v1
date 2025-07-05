import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'core/responsive/wrapper/responsive_layout.dart';
import 'data/local/models/index_model_extention.dart';
import 'data/local/providers/hive_provider.dart';
import 'data/remote/providers/firebase_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.openBox<Chantier>('chantiers');
  await Hive.openBox<ChantierEtape>('chantierEtapes');
  await Hive.openBox<Technicien>('techniciens');
  await Hive.openBox<Client>('clients');
  await Hive.openBox<Intervention>('interventions');
  await Hive.openBox<Piece>('pieces');
  await Hive.openBox<PieceJointe>('piecesJointes');
  await Hive.openBox<Materiel>('materiels');
  await Hive.openBox<Materiau>('materiau');
  await Hive.openBox<MainOeuvre>('mainOeuvre');

  runApp(const ProviderScope(child: AppInitializer()));
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(hiveInitProvider);

    return init.when(
      loading:
          () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (err, stack) => MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Erreur d\'init Hive: $err')),
            ),
          ),
      data: (_) => const MyApp(), // <-- ton app principale
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitializationProvider);
    setAuthRef(ref);
    final router = ref.watch(goRouterProvider);

    return firebaseInit.when(
      data:
          (app) => MaterialApp.router(
            title: 'BatTrack',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: ThemeMode.system,
            routerConfig: router,
            builder: (context, child) => ResponsiveObserver(child: child!),
          ),
      loading:
          () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (e, st) => MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Erreur d\'initialisation Firebase')),
            ),
          ),
    );
  }
}
