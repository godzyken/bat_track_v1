import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_models/shared_models.dart';
import '../../../../models/providers/synchrones/facture_sync_provider.dart';

final factureListProvider = FutureProvider.autoDispose<List<Facture>>((ref) {
  final service = ref.watch(factureSyncServiceProvider);
  return service.getAll();
});
