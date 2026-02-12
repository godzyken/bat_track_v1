import 'dart:async';

import 'package:bat_track_v1/data/core/unified_model_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  /// Helper pour attendre qu'un provider atteigne un état spécifique
  static Future<T> waitForProviderState<T>(
    ProviderContainer container,
    ProviderBase<AsyncValue<T>> provider,
    bool Function(AsyncValue<T>) condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<T>();
    late ProviderSubscription subscription;

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Provider state timeout'));
      }
    });

    subscription = container.listen(provider, (previous, next) {
      if (condition(next) && !completer.isCompleted) {
        timer.cancel();
        subscription.close();
        completer.complete(next.value!);
      }
    });

    return completer.future;
  }

  /// Helper pour vérifier l'égalité profonde des listes UnifiedModel
  static bool deepEquals<T extends UnifiedModel>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i].toJson().toString() != b[i].toJson().toString()) {
        return false;
      }
    }
    return true;
  }

  /// Matcher personnalisé pour vérifier AsyncValue
  static Matcher asyncValueEquals<T>(T expected) {
    return predicate<AsyncValue<T>>(
      (asyncValue) => asyncValue.hasValue && asyncValue.value == expected,
      'AsyncValue with value $expected',
    );
  }

  /// Matcher pour vérifier les listes AsyncValue
  static Matcher asyncListContains<T>(T item) {
    return predicate<AsyncValue<List<T>>>(
      (asyncValue) => asyncValue.hasValue && asyncValue.value!.contains(item),
      'AsyncValue<List> containing $item',
    );
  }
}
