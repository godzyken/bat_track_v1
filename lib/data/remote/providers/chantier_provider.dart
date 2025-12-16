import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/chantier/controllers/notifiers/chantier_notifier.dart';
import '../../local/models/index_model_extention.dart';
import '../../local/providers/hive_provider.dart';

final chantierFutureProvider = FutureProvider.family<Chantier?, String>((
  ref,
  id,
) async {
  final service = ref.read(chantierServiceProvider);
  return service.getRemote(id);
});

final chantierAdvancedNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ChantierNotifier, Chantier?, String>(ChantierNotifier.new);
