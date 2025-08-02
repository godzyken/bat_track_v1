import 'package:bat_track_v1/models/data/state_wrapper/wrappers_errors.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  final AppLogger logger;

  LoggingNavigatorObserver({required this.logger});

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('REPLACE', newRoute, oldRoute);
  }

  void _logNavigation(String action, Route? route, Route? previousRoute) {
    final newRouteName = route?.settings.name ?? route?.settings.toString();
    final oldRouteName =
        previousRoute?.settings.name ?? previousRoute?.settings.toString();

    final message = '$action: from [$oldRouteName] to [$newRouteName]';
    logger.info(message);

    // Envoie aussi à Sentry, optionnel
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'navigation',
        message: message,
        level: SentryLevel.info,
      ),
    );
  }
}
