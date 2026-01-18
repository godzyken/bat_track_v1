import 'package:bat_track_v1/data/remote/providers/multi_backend_remote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/entity_providers.dart';
import '../../local/models/utilisateurs/client.dart';

final clientsProvider = FutureProvider<List<Client>>((ref) async {
  final service = ref.watch(clientServiceProvider);
  // getAll() récupère en local (rapide) et synchronise si besoin
  return await service.getAll();
});

final syncClientsProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(multiBackendRemoteProvider);

  // Import Dolibarr → Firebase
  final dolibarrClients = storage.watchCollectionRaw('clients');

  final clientService = ref.read(clientServiceProvider);

  final list = await dolibarrClients.toList();

  for (var clients in list) {
    await clientService.saveRemote(single(clients));
  }
});

Client single(List<Map<String, dynamic>> clients) => clients.single as Client;
