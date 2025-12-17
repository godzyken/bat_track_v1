import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/documents/facture.dart';
import '../../../../models/providers/synchrones/facture_sync_provider.dart';

final factureListProvider = FutureProvider.autoDispose<List<Facture>>((ref) {
  final service = ref.watch(factureSyncServiceProvider);
  return service.getAll();
});
