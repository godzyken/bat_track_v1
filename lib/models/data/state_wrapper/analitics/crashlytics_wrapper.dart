import 'dart:developer' as developer;

import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../data/remote/providers/catch_error_provider.dart';

class CrashlyticsWrapper {
  static Future<void> captureException(
    Object error,
    StackTrace stack,
    Reader? ref,
  ) async {
    try {
      final user = ref!(appUserProvider).maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

      final userId = user?.id ?? 'anonymous';

      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'Handled by CrashlyticsWrapper',
        fatal: false,
        information: ['userId: $userId'],
      );
    } catch (e, s) {
      // Ne jamais lancer d'erreur dans la fonction de log elle-même !
      developer.log('CrashlyticsWrapper error: $e', stackTrace: s);
    }
  }
}

class SentryWrapper {
  static Future<void> captureException(
    Object exception,
    StackTrace stack, {
    String? hint,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stack,
      hint: Hint.withViewHierarchy(
        SentryAttachment.fromViewHierarchy(SentryViewHierarchy(hint!)),
      ),
    );
  }

  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) {
    return Sentry.captureMessage(message, level: level);
  }
}
