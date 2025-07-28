import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/responsive/wrapper/responsive_layout.dart';
import 'data/local/providers/hive_provider.dart';
import 'data/local/providers/shared_preferences_provider.dart';
import 'data/remote/providers/firebase_providers.dart';
import 'features/parametres/affichage/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
      child: AppInitializer(),
    ),
  );
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(hiveInitProvider);

    return init.when(
      loading: () => const LoadingApp(),
      error: (err, stack) => ErrorApp(message: 'Erreur Hive: $err'),
      data: (_) => const MyApp(),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitializationProvider);
    setAuthRef(
      ref,
    ); // 🔐 Explicite que ça initialise un contexte global Firebase
    final router = ref.watch(goRouterProvider);

    return firebaseInit.when(
      data:
          (_) => MaterialApp.router(
            title: 'BatTrack',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            builder: (context, child) => ResponsiveObserver(child: child!),
          ),
      loading: () => const LoadingApp(),
      error: (e, st) => ErrorApp(message: 'Erreur Firebase: $e'),
    );
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String message;

  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Center(child: Text(message))));
  }
}
