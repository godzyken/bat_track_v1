import 'package:bat_track_v1/data/local/models/documents/pieces_jointes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/entity_providers.dart';
import '../../../../core/riverpod/base_list_notifier.dart';

class DocumentListNotifier extends BaseListNotifier<PieceJointe> {
  @override
  Future<List<PieceJointe>> fetchAll() =>
      ref.read(pieceJointeServiceProvider).getAll();
  @override
  Future<void> save(PieceJointe item) =>
      ref.read(pieceJointeServiceProvider).save(item);
  @override
  Future<void> delete(String id) =>
      ref.read(pieceJointeServiceProvider).delete(id);
  @override
  Future<void> addItem(PieceJointe item) =>
      ref.read(pieceJointeServiceProvider).save(item);
}

final documentListProvider =
    AsyncNotifierProvider<DocumentListNotifier, List<PieceJointe>>(
      () => DocumentListNotifier(),
    );
