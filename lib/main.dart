import 'dart:ui';

import 'package:bat_track_v1/models/views/widgets/log_console.dart';
import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/responsive/wrapper/responsive_layout.dart';
import 'data/local/providers/hive_provider.dart';
import 'data/local/providers/shared_preferences_provider.dart';
import 'data/remote/providers/catch_error_provider.dart';
import 'data/remote/providers/firebase_providers.dart';
import 'features/parametres/affichage/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  /// Initialise le container à l'extérieur pour l'utiliser globalement
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
  );

  /// Gestion globale des erreurs
  FlutterError.onError = (details) {
    container
        .read(loggerProvider)
        .e(
          'Flutter Error',
          error: details.exception,
          stackTrace: details.stack,
        );
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    container
        .read(loggerProvider)
        .e('Platform Error', error: error, stackTrace: stack);
    Sentry.captureException(error, stackTrace: stack);
    return true;
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AppInitializer(),
    ),
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

    setAuthRef(ref); // Initialise FirebaseAuth dans le contexte

    return firebaseInit.when(
      loading: () => const LoadingApp(message: 'Initialisation Firebase...'),
      error: (err, _) => ErrorApp(message: 'Erreur Firebase: $err'),
      data:
          (_) => MaterialApp.router(
            title: 'BatTrack',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            builder: (context, child) => ResponsiveObserver(child: child!),
          ),
    );
  }
}

class LoadingApp extends StatelessWidget {
  final String message;
  const LoadingApp({super.key, this.message = 'Chargement...'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              const LogConsole(),
            ],
          ),
        ),
      ),
    );
  }
}
