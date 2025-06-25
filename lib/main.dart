import 'package:bat_track_v1/core/config/wrapper/responsive_wrapper.dart';
import 'package:bat_track_v1/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
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
      builder: (context, child) => ResponsiveWrapper(child: child!),
    );
  }
}
