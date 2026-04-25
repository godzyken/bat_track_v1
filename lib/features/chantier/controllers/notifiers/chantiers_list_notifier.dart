import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/riverpod/base_list_notifier.dart';
import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';

class ChantierListNotifier extends BaseListNotifier<Chantier> {
  @override
  Future<List<Chantier>> fetchAll() =>
      ref.read(chantierServiceProvider).getAll();

  @override
  Future<void> save(Chantier item) =>
      ref.read(chantierServiceProvider).save(item);

  @override
  Future<void> delete(String id) =>
      ref.read(chantierServiceProvider).delete(id);
}

// Provider déclaré manuellement
final chantierListProvider =
    AsyncNotifierProvider<ChantierListNotifier, List<Chantier>>(
      ChantierListNotifier.new,
    );
