import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/index_model_extention.dart';
import '../../data/adapter/triple_adapter.dart';

final chantierAdapterProvider = Provider<TripleAdapter<Chantier>>((ref) {
  return TripleAdapter<Chantier>(
    fromJson: (json) => Chantier.fromJson(json),
    collectionPath: 'chantiers',
    dolibarrEndpoint: 'chantiers',
    ref: ref,
  );
});
