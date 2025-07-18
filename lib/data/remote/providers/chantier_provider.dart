import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/models/chantier.dart';
import '../../local/providers/hive_provider.dart';

final chantierFutureProvider = FutureProvider.family<Chantier?, String>((
  ref,
  id,
) async {
  final service = ref.read(chantierServiceProvider);
  return service.getById(id);
});
