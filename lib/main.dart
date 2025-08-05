import 'dart:async';

import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/responsive/wrapper/responsive_layout.dart';
import 'data/local/providers/hive_provider.dart';
import 'data/local/providers/shared_preferences_provider.dart';
import 'data/remote/providers/catch_error_provider.dart';
import 'data/remote/providers/firebase_providers.dart';
import 'features/parametres/affichage/themes/theme.dart';
import 'models/views/screens/exeception_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ DOIT être en DEHORS

  runZonedGuarded(
    () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
      );

      await container.read(firebaseInitializationProvider.future);
      container.read(errorLoggerProvider).catcherFlutterError(container.read);

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const AppInitializer(),
        ),
      );
    },
    (error, stack) {
      // ✅ Logging d’erreur global
      debugPrint('Uncaught error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveInit = ref.watch(hiveInitProvider);

    return hiveInit.when(
      loading: () => const LoadingApp(message: 'Initialisation Hive...'),
      error: (err, _) => ErrorApp(message: 'Erreur Hive: $err'),
      data: (_) => const MyApp(),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitializationProvider);
    final router = ref.watch(goRouterProvider);

    return firebaseInit.when(
      loading: () => const LoadingApp(message: 'Initialisation Firebase...'),
      error: (err, _) => ErrorApp(message: 'Erreur Firebase: $err'),
      data: (_) {
        setAuthRef(ref);

        return MaterialApp.router(
          title: 'BatTrack',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          builder: (context, child) => ResponsiveObserver(child: child!),
        );
      },
    );
  }
}
