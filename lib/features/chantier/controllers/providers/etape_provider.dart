import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

final etapeProvider = Provider.family<ChantierEtape?, String>((ref, etapeId) {
  final chantier = ref.watch(chantierNotifierProvider('chantierId'));
  return chantier?.etapes.firstWhereOrNull((e) => e.id == etapeId);
});
