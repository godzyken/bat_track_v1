import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../models/providers/asynchrones/entity_list_future_provider.dart';

final cashflowProjectionProvider = FutureProvider<CashflowProjection>((
  ref,
) async {
  final List<Chantier> chantiersAsync = await ref.watch(
    allChantiersFutureProvider.future,
  );
  final List<Facture> facturesAsync = await ref.watch(
    allFacturesFutureProvider.future,
  );

  return ProjectionEngine.calculate(chantiersAsync, facturesAsync);
});
