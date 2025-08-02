import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../data/remote/providers/catch_error_provider.dart';
import '../data/remote/providers/dolibarr_instance_provider.dart';
import '../routes/app_routes.dart';

final dioProvider = Provider<Dio>((ref) {
  final instance = ref.watch(selectedInstanceProvider);
  final router = ref.watch(goRouterProvider);
  final logger = ref.read(loggerProvider);

  final dio = Dio(BaseOptions(baseUrl: instance?.baseUrl ?? ''));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['DOLAPIKEY'] = instance?.apiKey ?? '';
        logger.i("Request[${options.method}] => PATH: ${options.path}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        logger.i(
          "Response[${response.statusCode}] => PATH: ${response.requestOptions.path}",
        );
        handler.next(response);
      },
      onError: (DioException err, handler) async {
        logger.e(
          "Error[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}",
        );
        await Sentry.captureException(err, stackTrace: handler);

        if (err.response?.statusCode == 401) {
          // Invalide -> on reset l'instance + on redirige
          await ref.read(selectedInstanceProvider.notifier).clear();
          router.go('/pick-instance'); // Redirige vers la sélection
        }
        handler.next(err);
      },
    ),
  );

  return dio;
});
