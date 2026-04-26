import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/data/state_wrapper/analitics/crashlytics_wrapper.dart';
import '../../../models/services/navigator_key_service.dart';
import '../providers/catch_error_provider.dart';

/// 🔐 Fournit une méthode `catchAsync()` pour gérer les erreurs dans AsyncNotifier
extension SafeAsyncExtension<T> on Future<T> {
  Future<T?> catchAsync(Ref ref, {String? context}) async {
    final logger = ref.read(loggerProvider);
    final ui = ref.watch(uiFeedbackProvider); // SnackBar, Alert, etc.
    try {
      return await this;
    } catch (error, stack) {
      logger.e('Erreur $context', error: error, stackTrace: stack);
      ui.showError('Erreur : $context');
      return null;
    }
  }
}

/// 🔧 Extension pour capturer les erreurs sur Future partout ailleurs
extension SafeAsyncX<T> on Future<T> {
  Future<T?> catchAsync(
    Ref ref, {
    String? context,
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    try {
      return await this;
    } catch (error, stack) {
      ref
          .read(loggerProvider)
          .e('Future Error: \$context', error: error, stackTrace: stack);
      CrashlyticsWrapper.captureException(error, stack, ref);
      onError?.call(error, stack);
      return null;
    }
  }
}

/// 💬 UI Feedback (snackbar/toast)
final uiFeedbackProvider = Provider((ref) => UiFeedback(ref));

class UiFeedback {
  final Ref ref;
  UiFeedback(this.ref);

  void showError(String message) {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
