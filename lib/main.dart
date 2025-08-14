import 'dart:async';

import 'package:bat_track_v1/models/views/widgets/debug_overlay.dart';
import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
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
import 'models/views/screens/exeception_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(
    () async {
      final firebaseContainer = ProviderContainer();
      await firebaseContainer.read(firebaseInitializationProvider.future);
      firebaseContainer.dispose();

      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
      );

      if (!kIsWeb) {
        container.read(errorLoggerProvider).catcherFlutterError(container.read);
      }

      runApp(
        SentryWidget(
          child: UncontrolledProviderScope(
            container: container,
            child: const AppInitializer(),
          ),
        ),
      );
      // TODO: Remove this line after sending the first sample event to sentry.
      await Sentry.captureException(Exception('This is a sample exception.'));
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
      builder:
          (context, child) => ResponsiveObserver(
            child: Stack(children: [child!, const DebugFloatingOverlay()]),
          ),
    );
  }
}
