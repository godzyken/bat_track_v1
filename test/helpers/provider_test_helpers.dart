import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/riverpod_test.dart';

class ProviderTestHelpers {
  /// Helper pour tester un provider avec overrides multiples
  static Future<void> testProviderWithOverrides<T>({
    required String description,
    required ProviderBase<T> provider,
    required List<Override> overrides,
    required List<dynamic> expectedStates,
    Duration? wait,
    VoidCallback? verify,
  }) async {
    testProvider<T>(
      description,
      provider: provider,
      overrides: overrides,
      expect: () => expectedStates,
      wait: wait,
      verify: verify,
    );
  }

  /// Helper pour créer des matchers personnalisés
  static Matcher hasAsyncValue<T>(T value) {
    return predicate<AsyncValue<T>>(
      (asyncValue) => asyncValue.hasValue && asyncValue.value == value,
      'AsyncValue with value $value',
    );
  }

  static Matcher hasAsyncError(String errorMessage) {
    return predicate<AsyncValue>(
      (asyncValue) =>
          asyncValue.hasError &&
          asyncValue.error.toString().contains(errorMessage),
      'AsyncValue with error containing "$errorMessage"',
    );
  }

  static Matcher hasAsyncListLength<T>(int length) {
    return predicate<AsyncValue<List<T>>>(
      (asyncValue) => asyncValue.hasValue && asyncValue.value!.length == length,
      'AsyncValue<List<T>> with length $length',
    );
  }
}
