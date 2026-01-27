import 'dart:async';

import 'package:bat_track_v1/models/views/widgets/debug_overlay.dart';
import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/responsive/wrapper/responsive_layout.dart';
import 'data/local/providers/hive_provider.dart';
import 'data/local/providers/shared_preferences_provider.dart';
import 'data/remote/providers/catch_error_provider.dart';
import 'features/parametres/affichage/themes/theme.dart';
import 'firebase_options.dart';
import 'models/views/screens/exeception_screens.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialisations asynchrones
      /*await Future.delayed(Duration(milliseconds: 100));

      final firebaseContainer = ProviderContainer();
      try {
        await firebaseContainer.read(firebaseInitializationProvider.future);
      } catch (e) {
        debugPrint('⚠️ Firebase initialization failed: $e');
      } finally {
        firebaseContainer.dispose();
      }*/
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialisation SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
      );

      // ✅ Initialise le gestionnaire d'erreurs global
      if (!kIsWeb) {
        try {
          container
              .read(errorLoggerProvider)
              .catcherFlutterError(container.read);
        } catch (e) {
          debugPrint('⚠️ Error logger initialization failed: $e');
        }
      }

      // ✅ Configure le gestionnaire d'erreurs Flutter
      FlutterError.onError = (FlutterErrorDetails details) {
        // Filtre les erreurs du DebugService et des assets
        if (_shouldIgnoreError(details)) {
          debugPrint('🔇 Ignored error: ${details.exception}');
          return;
        }

        // Log l'erreur
        debugPrint('❌ Flutter Error: ${details.exception}');
        if (kDebugMode) {
          FlutterError.presentError(details);
        }

        // Envoie à Sentry en production
        if (!kDebugMode) {
          Sentry.captureException(details.exception, stackTrace: details.stack);
        }
      };

      runApp(
        SentryWidget(
          child: UncontrolledProviderScope(
            container: container,
            child: const AppInitializer(),
          ),
        ),
      );
    },
    (error, stack) {
      // ✅ Gestion des erreurs non capturées
      if (_shouldIgnoreErrorString(error.toString())) {
        debugPrint('🔇 Ignored uncaught error: $error');
        return;
      }

      debugPrint('❌ Uncaught error: $error');
      debugPrintStack(stackTrace: stack);

      if (!kDebugMode) {
        Sentry.captureException(error, stackTrace: stack);
      }
    },
  );
}

/// ✅ Filtre les erreurs non critiques
bool _shouldIgnoreError(FlutterErrorDetails details) {
  return _shouldIgnoreErrorString(details.exception.toString());
}

bool _shouldIgnoreErrorString(String error) {
  return error.contains('DebugService') ||
      error.contains('Cannot send Null') ||
      error.contains('Unable to load asset') ||
      error.contains('asset does not exist') ||
      error.contains('HTTP status 404');
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
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'BatTrack',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        badgeTheme: lightTheme.badgeTheme,
        appBarTheme: lightTheme.appBarTheme,
        textTheme: lightTheme.textTheme,
        actionIconTheme: lightTheme.actionIconTheme,
        bannerTheme: lightTheme.bannerTheme,
        bottomNavigationBarTheme: lightTheme.bottomNavigationBarTheme,
        cardTheme: lightTheme.cardTheme,
        chipTheme: lightTheme.chipTheme,
        colorScheme: lightTheme.colorScheme,
        elevatedButtonTheme: lightTheme.elevatedButtonTheme,
        inputDecorationTheme: lightTheme.inputDecorationTheme,
        listTileTheme: lightTheme.listTileTheme,
        navigationRailTheme: lightTheme.navigationRailTheme,
        outlinedButtonTheme: lightTheme.outlinedButtonTheme,
        pageTransitionsTheme: lightTheme.pageTransitionsTheme,
        radioTheme: lightTheme.radioTheme,
        scaffoldBackgroundColor: lightTheme.scaffoldBackgroundColor,
        snackBarTheme: lightTheme.snackBarTheme,
        switchTheme: lightTheme.switchTheme,
        textButtonTheme: lightTheme.textButtonTheme,
        textSelectionTheme: lightTheme.textSelectionTheme,
        toggleButtonsTheme: lightTheme.toggleButtonsTheme,
        tooltipTheme: lightTheme.tooltipTheme,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) => ResponsiveObserver(
        child: Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (kDebugMode) const DebugFloatingOverlay(),
          ],
        ),
      ),
    );
  }
}
