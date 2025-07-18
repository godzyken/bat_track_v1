import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/providers/dolibarr_instance_provider.dart';
import '../routes/app_routes.dart';

final dioProvider = Provider<Dio>((ref) {
  final instance = ref.watch(selectedInstanceProvider);
  final router = ref.watch(goRouterProvider);

  final dio = Dio(BaseOptions(baseUrl: instance?.baseUrl ?? ''));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['DOLAPIKEY'] = instance?.apiKey ?? '';
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Invalide -> on reset l'instance + on redirige
          await ref.read(selectedInstanceProvider.notifier).clear();
          router.go('/pick-instance'); // Redirige vers la sélection
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
