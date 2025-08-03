typedef FallbackBuilder<T> = T Function();

class FallbackFactory {
  static final Map<Type, dynamic Function()> _fallbacks = {};

  static void register<T>(T Function() builder) {
    _fallbacks[T] = builder;
  }

  static T get<T>() {
    final builder = _fallbacks[T];
    if (builder == null) {
      throw UnimplementedError('Aucun fallback enregistré pour $T');
    }
    return builder() as T;
  }

  static bool has<T>() => _fallbacks.containsKey(T);
}
