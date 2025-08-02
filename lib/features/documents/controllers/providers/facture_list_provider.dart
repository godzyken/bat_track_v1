import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/documents/facture.dart';
import '../../../chantier/controllers/providers/chantier_sync_provider.dart';

final factureListProvider = FutureProvider.autoDispose<List<Facture>>((ref) {
  final service = ref.watch(factureSyncServiceProvider);
  return service.getAll();
});
