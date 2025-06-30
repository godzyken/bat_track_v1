import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../notifiers/chantier_notifier.dart';

final etapeProvider = Provider.family<ChantierEtape?, String>((ref, etapeId) {
  final chantier = ref.watch(chantierNotifierProvider);
  return chantier?.etapes.firstWhereOrNull((e) => e.id == etapeId);
});
