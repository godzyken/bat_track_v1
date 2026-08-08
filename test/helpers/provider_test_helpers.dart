import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class ProviderTestHelpers {
  /// Helper pour tester un provider avec overrides multiples
  static Future<void> testProviderWithOverrides<T>({
    required String description,
    required dynamic provider,
    required List<dynamic> overrides,
    required List<T> expectedStates,
    Duration? wait,
    void Function(T state)? verify,
  }) async {
    test(description, () async {
      final container = ProviderContainer(
        overrides: [
          for (final dynamic o in overrides) o,
        ],
      );
      addTearDown(container.dispose);

      final states = <T>[];
      container.listen<T>(
        provider as dynamic,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      if (wait != null) {
        await Future.delayed(wait);
      }

      expect(states, expectedStates);
      if (verify != null) {
        verify(container.read(provider as dynamic));
      }
    });
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
