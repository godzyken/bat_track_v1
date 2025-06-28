import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local/providers/hive_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    setAuthRef(ref);
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'BatTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) => ResponsiveObserver(child: child!),
    );
  }
}
