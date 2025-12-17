import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/remote/services/dolibarr_services.dart';
import '../../../features/auth/data/providers/current_user_provider.dart';
import '../../../features/chantier/controllers/providers/chantier_sync_provider.dart';
import '../../providers/asynchrones/error_logger_provider.dart';
import '../../providers/synchrones/facture_sync_provider.dart';

extension UserImportPermissions on UserModel {
  bool get canImportClients => role.can('import_clients');

  bool get canImportProduits => role.can('import_produits');

  bool get canImportChantiers => role.can('import_chantiers');

  bool get canImportProjets => role.can('import_projets');

  bool get canImportFactures => role.can('import_factures');

  bool get canImportTechniciens => role.can('import_techniciens');
}

extension UserRolePermissions on UserRole {
  bool can(String permission) {
    switch (this) {
      case UserRole.superUtilisateur:
        return true;
      case UserRole.chefDeProjet:
        return [
          'import_clients',
          'import_chantiers',
          'import_projects',
          'import_invoices',
          'import_products',
          'import_techniciens',
        ].contains(permission);
      case UserRole.technicien:
        return ['import_chantiers'].contains(permission);
      case UserRole.client:
        return false;
    }
  }
}

class DolibarrImporter {
  final DolibarrApiService api;
  final Ref ref;

  DolibarrImporter(this.api, this.ref);

  Future<Map<String, int>> importData({
    bool importClients = true,
    bool importProducts = true,
    bool importChantiers = true,
    bool importProjects = true,
    bool importInvoices = true,
    bool importIntervenants = true,
  }) async {
    final log = ref.read(errorLoggerProvider);
    final user = ref.read(currentUserProvider);
    final Map<String, int> summary = {};

    Future<void> safeImport(
      String label,
      bool enabled,
      bool Function(UserModel user) rule,
      Future<int> Function() importFn,
    ) async {
      if (!enabled) return;
      if (!rule(user.value!.toUserModel())) {
        log.logWarning('Droit refusé pour l\'import $label');
        return;
      }
      try {
        final count = await importFn();
        summary[label] = count;
        log.logInfo('Import $label réussi ($count éléments)');
      } catch (e, st) {
        log.logError(e, st, 'Import $label échoué');
      }
    }

    await safeImport(
      'clients',
      importClients,
      (u) => u.canImportClients,
      _importClients,
    );
    await safeImport(
      'produits',
      importProducts,
      (u) => u.canImportProduits,
      _importProducts,
    );
    await safeImport(
      'chantiers',
      importChantiers,
      (u) => u.canImportChantiers,
      _importChantiers,
    );
    await safeImport(
      'projets',
      importProjects,
      (u) => u.canImportProjets,
      _importProjects,
    );
    await safeImport(
      'factures',
      importInvoices,
      (u) => u.canImportFactures,
      _importInvoices,
    );
    await safeImport(
      'intervenants',
      importIntervenants,
      (u) => u.canImportTechniciens,
      _importIntervenants,
    );

    log.logInfo('✅ Résumé de la synchronisation Dolibarr :');
    summary.forEach((key, count) {
      log.logInfo('  ➤ $key : $count entités importées');
    });

    return summary;
  }

  Future<int> _importClients() async {
    final list = await api.fetchClients();
    final items = list.map((e) => Client.fromJson(e)).toList();
    final service = ref.read(clientSyncServiceProvider);
    for (final item in items) {
      await service.save(item);
    }
    return items.length;
  }

  Future<int> _importProducts() async {
    final list = await api.fetchProducts();
    final items = list.map((e) => Materiau.fromJson(e)).toList();
    final service = ref.read(materiauSyncServiceProvider);
    for (final item in items) {
      await service.save(item);
    }
    return items.length;
  }

  Future<int> _importChantiers() async {
    final list = await api.fetch('chantiers');
    final items = list.map((e) => Chantier.fromJson(e)).toList();
    final service = ref.read(chantierSyncServiceProvider);
    for (final item in items) {
      await service.save(item);
    }
    return items.length;
  }

  Future<int> _importProjects() async {
    final list = await api.fetchProjects();
    final items = list.map((e) => Projet.fromJson(e)).toList();
    final service = ref.read(projetSyncServiceProvider);
    for (final item in items) {
      await service.save(item);
    }
    return items.length;
  }

  Future<int> _importInvoices() async {
    final list = await api.fetchInvoices();
    final items = list.map((e) => Facture.fromJson(e)).toList();
    final service = ref.read(factureSyncServiceProvider);
    for (final item in items) {
      await service.save(item);
    }
    return items.length;
  }

  Future<int> _importIntervenants() async {
    final list = await api.fetchIntervenants();
    final items = list.map((e) => Technicien.fromJson(e)).toList();
    final service = ref.read(techSyncServiceProvider);
    for (final item in items) {
      await service.save(item);
    }
    return items.length;
  }
}
