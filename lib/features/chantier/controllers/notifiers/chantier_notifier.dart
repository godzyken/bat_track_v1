import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';

class ChantierNotifier extends StateNotifier<Chantier?> {
  ChantierNotifier() : super(null);

  // Injecte ton service Hive ici
  final EntityService<Chantier> _service = chantierService;

  Future<void> load(String chantierId) async {
    state = null;
    await Future.delayed(const Duration(seconds: 1));

    final chantier = await _service.get(chantierId);
    state = chantier;
  }

  Future<void> addPieceJointe(String etapeId, PieceJointe piece) async {
    if (state == null) return;

    final etapes =
        state!.etapes.map((e) {
          if (e.id == etapeId) {
            final updatedPieces = List<PieceJointe>.from(e.piecesJointes ?? [])
              ..add(piece);
            return e.copyWith(piecesJointes: updatedPieces);
          }
          return e;
        }).toList();

    final updatedChantier = state!.copyWith(etapes: etapes);

    await _service.update(updatedChantier, updatedChantier.id);

    state = updatedChantier;
  }

  Future<void> addEtape(ChantierEtape etape) async {
    if (state == null) return;
    final updatedEtapes = List<ChantierEtape>.from(state!.etapes)..add(etape);
    final updatedChantier = state!.copyWith(etapes: updatedEtapes);
    await _service.update(updatedChantier, updatedChantier.id);
    state = updatedChantier;
  }

  Future<void> updateEtape(ChantierEtape etape) async {
    if (state == null) return;

    final etapes =
        state!.etapes.map((e) {
          if (e.id == etape.id) {
            return etape;
          }
          return e;
        }).toList();
    final updatedChantier = state!.copyWith(etapes: etapes);
    await _service.update(updatedChantier, updatedChantier.id);
    state = updatedChantier;
  }

  Future<void> deleteEtape(String etapeId) async {
    if (state == null) return;
    final etapes = state!.etapes.where((e) => e.id != etapeId).toList();
    final updatedChantier = state!.copyWith(etapes: etapes);
    await _service.update(updatedChantier, updatedChantier.id);
    state = updatedChantier;
  }

  Future<void> deletePieceJointe(String etapeId, String pieceId) async {
    if (state == null) return;
    final etapes =
        state!.etapes.map((e) {
          if (e.id == etapeId) {
            final updatedPieces =
                e.piecesJointes?.where((p) => p.id != pieceId).toList();
            return e.copyWith(piecesJointes: updatedPieces);
          }
          return e;
        }).toList();
    final updatedChantier = state!.copyWith(etapes: etapes);
    await _service.update(updatedChantier, updatedChantier.id);
    state = updatedChantier;
  }

  Future<void> toggleTerminee(String etapeId) async {
    if (state == null) return;

    final etapes =
        state!.etapes.map((e) {
          if (e.id == etapeId) {
            return e.copyWith(terminee: !e.terminee);
          }
          return e;
        }).toList();

    final updatedChantier = state!.copyWith(etapes: etapes);

    await _service.update(updatedChantier, updatedChantier.id);

    state = updatedChantier;
  }
}

final chantierNotifierProvider =
    StateNotifierProvider<ChantierNotifier, Chantier?>(
      (ref) => ChantierNotifier(),
    );
