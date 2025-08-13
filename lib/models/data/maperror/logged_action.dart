import 'dart:convert';

import 'package:bat_track_v1/models/data/maperror/log_entry.dart';
import 'package:bat_track_v1/models/notifiers/logged_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../adapter/typedefs.dart';

mixin LoggedAction {
  late Reader _ref;

  void initLogger(Reader ref) {
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

    _ref(loggerNotifierProvider.notifier).log(message);
  }

  void logEvent({
    required String name,
    dynamic data,
    String? target,
    bool captureToSentry = true,
  }) {
    final message = LogEntry(
      timestamp: DateTime.now(),
      data: data,
      action: name,
      target: target!,
    );

    debugPrint("LOGGED EVENT: ${jsonEncode(message)}");

    if (captureToSentry) {
      Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(message.toString()),
          unknown: data,
          tags: {'event_type': 'business'},
        ),
      );
    }
    _ref(loggerNotifierProvider.notifier).log(message);
  }

  void logError({
    required String name,
    dynamic data,
    String? target,
    bool captureToSentry = true,
  }) {
    final message = LogEntry(
      timestamp: DateTime.now(),
      data: data,
      action: name,
      target: target!,
    );
    debugPrint("LOGGED ERROR: ${jsonEncode(message)}");

    if (captureToSentry) {
      Sentry.captureException(
        SentryEvent(
          message: SentryMessage(message.toString()),
          unknown: data,
          tags: {'event_type': 'business'},
        ),
      );
    }
    _ref(loggerNotifierProvider.notifier).log(message);
  }
}
