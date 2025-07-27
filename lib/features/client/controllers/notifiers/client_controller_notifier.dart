import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../data/local/models/utilisateurs/client.dart';
import '../../../../data/remote/providers/dolibarr_config_provider.dart';
import '../../../../data/remote/services/dolibarr_services.dart';

class ClientController extends AsyncNotifier<void> {
  late final DolibarrApiService api;

  @override
  Future<void> build() async {
    api = ref.read(dolibarrApiProvider);
  }

  Future<void> importClients() async {
    final clientsJson = await api.fetchClients();
    final clients = clientsJson.map(Client.fromJson).toList();

    for (var client in clients) {
      await Hive.box<Client>('clients').put(client.id, client);
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(client.id)
          .set(client.toJson());
    }
  }
}
