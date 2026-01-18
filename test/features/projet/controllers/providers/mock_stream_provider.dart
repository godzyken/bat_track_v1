import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simule un StreamProvider pour tests.
///
/// [snapshots] : liste de listes de T à émettre successivement.
/// [errors] : Exceptions ou Strings pour les erreurs.
/// [delay] : délai entre les snapshots (optionnel).
Stream<List<T>> Function(Ref) mockStreamProvider<T>({
  required List<List<T>> snapshots,
  Map<int, Object>? errors,
  Duration delay = const Duration(milliseconds: 10),
}) {
  return (ref) async* {
    List<T>? lastValidSnapshot;

    for (var i = 0; i < snapshots.length; i++) {
      await Future.delayed(delay);

      if (errors != null && errors.containsKey(i)) {
        final err = errors[i]!;
        developer.log('⚠️ Simulated error at snapshot $i: $err');

        // Yield last snapshot or empty to continue the stream
        yield lastValidSnapshot ?? [];

        // Le test devra vérifier "hasError" séparément
        continue;
      }

      final snapshot = snapshots[i];
      yield snapshot;
      lastValidSnapshot = snapshot;
      developer.log('✅ Yield snapshot $i: $snapshot');
    }
  };
}
