import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/data/adapter/triple_adapter.dart';
import '../../../models/data/json_model.dart';
import '../../local/models/index_model_extention.dart';

class DolibarrSyncService {
  final Ref ref;

  DolibarrSyncService(this.ref);

  Future<void> syncAllFromDolibarr(BuildContext context) async {
    final syncs = <Future Function()>[
      () => _syncModel<Client>(
        context: context,
        factory: () => Client.mock(),
        collection: 'clients',
        endpoint: 'thirdparties',
      ),
      () => _syncModel<Chantier>(
        context: context,
        factory: () => Chantier.mock(),
        collection: 'chantiers',
        endpoint: 'projects',
      ),
      () => _syncModel<Intervention>(
        context: context,
        factory: () => Intervention.mock(),
        collection: 'interventions',
        endpoint: 'interventions',
      ),
      () => _syncModel<Technicien>(
        context: context,
        factory: () => Technicien.mock(),
        collection: 'techniciens',
        endpoint: 'techniciens',
      ),
    ];

    for (final sync in syncs) {
      try {
        await sync();
      } catch (e) {
        if (context.mounted) {
          _showSnack(context, "Erreur pendant la synchro : $e");
        }
      }
    }

    if (context.mounted) {
      _showSnack(context, "Synchronisation complète !");
    }
  }

  Future<void> _syncModel<T extends JsonModel>({
    required BuildContext context,
    required T Function() factory,
    required String collection,
    required String endpoint,
  }) async {
    final adapter = TripleAdapter<T>(
      ref: ref,
      factory: factory,
      collectionPath: collection,
      dolibarrEndpoint: endpoint,
    );

    final items = await adapter.fetchFromDolibarr();
    final box = await adapter.getHiveBox();

    for (final item in items) {
      await adapter.saveToFirebase(item as dynamic);
      await adapter.saveToHive(box, item as dynamic);
    }

    if (context.mounted) {
      _showSnack(
        context,
        "$collection : ${items.length} éléments synchronisés",
      );
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
