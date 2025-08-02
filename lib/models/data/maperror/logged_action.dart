import 'dart:convert';

import 'package:bat_track_v1/models/data/maperror/log_entry.dart';
import 'package:bat_track_v1/models/notifiers/logged_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin LoggedAction {
  late Ref _ref;

  void initLogger(Ref ref) {
    _ref = ref;
  }

  void logAction({
    required String action,
    String? target,
    dynamic data,
    bool captureToSentry = true,
  }) {
    final message = LogEntry(
      timestamp: DateTime.now(),
      action: action,
      target: target!,
      data: data,
    );

    debugPrint('LOGGED ACTION: ${jsonEncode(message)}');

    if (captureToSentry) {
      Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(message.toString()),
          unknown: {'target': target, ...?data},
          tags: {'event_type': 'user_action'},
        ),
      );
    }

    _ref.read(loggerNotifierProvider.notifier).log(message);
  }

  void logEvent({
    required String name,
    Map<String, dynamic>? data,
    bool captureToSentry = true,
  }) {
    final message = '[EVENT] $name';
    debugPrint(message);

    if (captureToSentry) {
      Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(message),
          unknown: data,
          tags: {'event_type': 'business'},
        ),
      );
    }
  }

  void logError({
    required String name,
    Map<String, dynamic>? data,
    bool captureToSentry = true,
  }) {
    final message = '[ERROR] $name';
    debugPrint(message);

    if (captureToSentry) {
      Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(message),
          unknown: data,
          tags: {'event_type': 'business'},
        ),
      );
    }
  }
}
