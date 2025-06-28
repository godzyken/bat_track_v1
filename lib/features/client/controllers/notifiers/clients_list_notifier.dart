import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

class ClientListNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    final service = ref.read(clientServiceProvider);
    return service.getAll();
  }

  Future<void> add(Client client) async {
    final service = ref.read(clientServiceProvider);
    await service.add(client, client.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> save(Client client) async {
    final service = ref.read(clientServiceProvider);
    await service.save(client, client.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> updateClient(Client client) async {
    final service = ref.read(clientServiceProvider);
    await service.update(client, client.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> delete(String id) async {
    final service = ref.read(clientServiceProvider);
    await service.delete(id);
    state = AsyncValue.data(await service.getAll());
  }
}

final clientListProvider =
    AsyncNotifierProvider<ClientListNotifier, List<Client>>(
      () => ClientListNotifier(),
    );
