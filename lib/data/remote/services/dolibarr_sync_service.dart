import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../models/data/adapter/triple_adapter.dart';
import '../../local/models/index_model_extention.dart';

class DolibarrSyncService {
  final Ref ref;

  DolibarrSyncService(this.ref);

  Future<void> syncAllFromDolibarr(BuildContext context) async {
    final syncs = <Future Function()>[
      () => _syncModel<Client>(
        context: context,
        fromJson: Client.fromJson,
        factory: () => Client.mock(),
        collection: 'clients',
        endpoint: 'thirdparties',
      ),
      () => _syncModel<Chantier>(
        context: context,
        fromJson: Chantier.fromJson,
        factory: () => Chantier.mock(),
        collection: 'chantiers',
        endpoint: 'projects',
      ),
      () => _syncModel<Intervention>(
        context: context,
        fromJson: Intervention.fromJson,
        factory: () => Intervention.mock(),
        collection: 'interventions',
        endpoint: 'interventions',
      ),
      () => _syncModel<Technicien>(
        context: context,
        fromJson: Technicien.fromJson,
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

  Future<void> _syncModel<T extends UnifiedModel>({
    required BuildContext context,
    required T Function() factory,
    required T Function(Map<String, dynamic>) fromJson,
    required String collection,
    required String endpoint,
  }) async {
    final adapter = TripleAdapter<T>(
      ref: ref,
      fromJson: fromJson,
      collectionPath: collection,
      dolibarrEndpoint: endpoint,
    );

    final items = await adapter.fetchFromDolibarr();
    final box = await adapter.getHiveBox();

    for (final item in items) {
      box.isOpen;

      await adapter.saveToFirebase(item as dynamic);
      await adapter.saveToHive(item as dynamic);
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
