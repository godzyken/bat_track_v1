import 'package:bat_track_v1/data/local/models/documents/pieces_jointes.dart';
import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentListNotifier extends EntityListNotifier<PieceJointe> {}

final documentListProvider =
    AsyncNotifierProvider<DocumentListNotifier, List<PieceJointe>>(
      () => DocumentListNotifier(),
    );
