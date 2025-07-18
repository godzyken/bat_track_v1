import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/service_type.dart';

class ChantierNotifier extends StateNotifier<Chantier?> {
  final String id;
  final Box<Chantier> chantierBox;
  final Box<ChantierEtape> etapeBox;
  final Box<Piece> pieceBox;
  final Box<PieceJointe> pieceJointeBox;
  final EntityServices<Chantier> chantierService;
  final EntityServices<ChantierEtape> etapeService;
  final EntityServices<Piece> pieceService;
  final EntityServices<PieceJointe> pieceJointeService;

  ChantierNotifier({
    required this.id,
    required this.chantierBox,
    required this.etapeBox,
    required this.pieceBox,
    required this.pieceJointeBox,
    required this.chantierService,
    required this.etapeService,
    required this.pieceService,
    required this.pieceJointeService,
  }) : super(chantierBox.get(id));

  List<ChantierEtape> get etapes =>
      etapeBox.values.where((e) => e.chantierId == id).toList();

  List<Piece> get pieces => pieceBox.values.where((p) => p.id == id).toList();

  List<PieceJointe> get piecesJointes =>
      pieceJointeBox.values.where((p) => p.id == id).toList();

  /// Update Model
  Future<void> updateChantier(Chantier chantier) async {
    await chantierBox.put(chantier.id, chantier);
    await chantierService.save(chantier, chantier.id);
    state = chantier;
  }

  Future<void> updateEtape(ChantierEtape etape) async {
    await etapeBox.put(etape.id, etape);
    await etapeService.save(etape, etape.id!);
  }

  Future<void> updatePiece(Piece piece) async {
    await pieceBox.put(piece.id, piece);
    await pieceService.save(piece, piece.id!);
  }

  Future<void> updatePieceJointe(PieceJointe piece) async {
    await pieceJointeBox.put(piece.id, piece);
    await pieceJointeService.save(piece, piece.id);
  }

  /// Add Model
  Future<void> addEtape(ChantierEtape etape) async {
    await etapeBox.put(etape.id, etape);
    await etapeService.save(etape, etape.id!);
  }

  Future<void> addPiece(Piece piece) async {
    await pieceBox.put(piece.id, piece);
    await pieceService.save(piece, piece.id!);
  }

  Future<void> addPieceJointe(String s, PieceJointe piece) async {
    await pieceJointeBox.put(s, piece);
    await pieceJointeService.save(piece, piece.id);
  }

  /// Delete Model
  Future<void> deleteEtape(String etapeId) async {
    await etapeBox.delete(etapeId);
    await etapeService.delete(etapeId);
  }

  Future<void> deletePiece(String pieceId) async {
    await pieceBox.delete(pieceId);
    await pieceService.delete(pieceId);
  }

  Future<void> deletePieceJointe(String pieceId) async {
    await pieceJointeBox.delete(pieceId);
    await pieceJointeService.delete(pieceId);
  }

  void toggleTerminee(String etapeId) {
    final current = state;
    if (current == null) return;

    final updatedEtapes =
        current.etapes.map((e) {
          if (e.id == etapeId) {
            return e.copyWith(terminee: !e.terminee);
          }
          etapeBox.put(e.id, e);
          etapeService.save(e, e.id!);
          return e;
        }).toList();

    final updatedChantier = current.copyWith(etapes: updatedEtapes);
    state = updatedChantier;
  }
}

final chantierAdvancedNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChantierNotifier, Chantier?, String>((ref, id) {
      final chantierBox = ref.watch(chantierNotifierProvider(id).notifier).box;
      final etapeBox =
          ref.watch(chantierEtapeNotifierProvider(id).notifier).box;
      final pieceBox = ref.watch(pieceNotifierProvider(id).notifier).box;
      final pieceJointeBox =
          ref.watch(pieceJointeNotifierProvider(id).notifier).box;

      return ChantierNotifier(
        id: id,
        chantierBox: chantierBox,
        etapeBox: etapeBox,
        pieceBox: pieceBox,
        pieceJointeBox: pieceJointeBox,
        chantierService: chantierService,
        etapeService: chantierEtapeService,
        pieceService: pieceService,
        pieceJointeService: pieceJointeService,
      );
    });
