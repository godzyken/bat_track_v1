import 'package:bat_track_v1/core/riverpod/base_list_notifier.dart';
import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

class ClientListNotifier extends BaseListNotifier<Client> {
  @override
  Future<List<Client>> fetchAll() => ref.read(clientServiceProvider).getAll();

  @override
  Future<void> save(Client item) => ref.read(clientServiceProvider).save(item);

  @override
  Future<void> delete(String id) => ref.read(clientServiceProvider).delete(id);
}

final clientListProvider =
    AsyncNotifierProvider<ClientListNotifier, List<Client>>(
      ClientListNotifier.new,
    );
