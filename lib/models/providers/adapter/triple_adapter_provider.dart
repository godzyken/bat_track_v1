import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/chantier.dart';
import '../../data/adapter/triple_adapter.dart';

final chantierAdapterProvider = Provider<TripleAdapter<Chantier>>((ref) {
  return TripleAdapter<Chantier>(
    factory: () => Chantier.mock(),
    collectionPath: 'chantiers',
    dolibarrEndpoint: 'chantiers',
    ref: ref,
  );
});
