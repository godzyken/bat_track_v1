import 'package:bat_track_v1/core/services/unified_entity_service.dart';
import 'package:bat_track_v1/models/providers/asynchrones/remote_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/models/utilisateurs/client.dart';

final clientsProvider = FutureProvider((ref) async {
  final storage = ref.read(remoteStorageServiceProvider);

  // Exemple: lire les clients depuis Supabase
  final service = UnifiedEntityService<Client>(
    collectionName: 'clients',
    fromJson: Client.fromJson,
    remoteStorage: storage,
  );

  return service.getAllRemote();
});

final syncClientsProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(remoteStorageServiceProvider);

  // Import Dolibarr → Firebase
  final dolibarrClients = storage.watchCollectionRaw('clients');

  final clientService = UnifiedEntityService<Client>(
    collectionName: 'clients',
    fromJson: Client.fromJson,
    remoteStorage: storage,
  );

  final list = await dolibarrClients.toList();

  for (var clients in list) {
    await clientService.saveRemote(single(clients));
  }
});

Client single(List<Map<String, dynamic>> clients) => clients.single as Client;
