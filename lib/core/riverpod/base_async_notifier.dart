import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseAsyncNotifier<T> extends AsyncNotifier<T> {
  // Raccourci pour éviter state = AsyncValue.loading() partout
  void setLoading() => state = const AsyncValue.loading();

  void setError(Object e, StackTrace st) => state = AsyncValue.error(e, st);

  void setData(T data) => state = AsyncValue.data(data);

  /// Guard sécurisé : gère loading/error automatiquement
  Future<void> guard(Future<T> Function() fn) async {
    setLoading();
    state = await AsyncValue.guard(fn);
  }
}
