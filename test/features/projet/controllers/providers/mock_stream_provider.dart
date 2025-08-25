import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simule un StreamProvider pour tests.
///
/// [snapshots] : liste de listes de T à émettre successivement.
/// [errorAt] : index où une erreur doit être simulée (optionnel).
/// [error] : Exception ou String pour l’erreur.
/// [delay] : délai entre les snapshots (optionnel).
Stream<List<T>> Function(Ref) mockStreamProvider<T>({
  required List<List<T>> snapshots,
  int? errorAt,
  Object? error,
  Duration delay = const Duration(milliseconds: 10),
}) {
  return (ref) async* {
    for (var i = 0; i < snapshots.length; i++) {
      await Future.delayed(delay);
      // si on est à l’index errorAt, yield une AsyncValue.error encapsulée
      if (errorAt != null && i == errorAt) {
        // on peut “injecter” une erreur mais continuer le stream
        yield snapshots[i]; // yield le snapshot avant erreur
        // yield un snapshot vide ou répéter le dernier pour simuler reconnection
        // ici on simule juste l’erreur en log
        print('⚠️ Simulated Firestore error: $error');
        continue; // stream continue
      }
      yield snapshots[i];
    }
  };
}
