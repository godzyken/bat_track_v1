import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bat_track_v1/models/data/adapter/typedefs.dart';
import 'package:bat_track_v1/models/data/maperror/log_entry.dart';
import 'package:bat_track_v1/models/notifiers/logged_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin LoggedAction {
  late Ref _ref;

  void initLogger(Reader refRead) {
    _ref = refRead as Ref;

    developer.log("🛠 Logger Initialisé pour $runtimeType");
  }

  void logAction({
    required String action,
    String? target,
    Map<String, dynamic>? data,
    bool captureToSentry = true,
  }) {
    final timestamp = DateTime.now();
    developer.log(">>>> [CONSOLE CHECK] $timestamp | $action | $target");
    final logger = _ref.read(loggerNotifierProvider.notifier);

    final message = LogEntry(
      timestamp: DateTime.now(),
      action: action,
      target: target ?? 'unknown',
      data: data,
    );

    logger.log(message);

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

    try {
      if (_ref != null) {
        _ref.watch(loggerNotifierProvider.notifier).log(message);
      }
    } catch (e) {
      developer.log("❌ Erreur lors de l'accès au loggerNotifierProvider: $e");
    }

    if (captureToSentry) {
      Sentry.captureMessage('Action: $action on $target');
    }
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
    _ref.read(loggerNotifierProvider.notifier).log(message);
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
    _ref.read(loggerNotifierProvider.notifier).log(message);
  }
}
