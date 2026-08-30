import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/models/index_model_extention.dart';
import '../../data/remote/providers/multi_backend_remote_provider.dart';
import '../../models/services/remote/remote_storage_service.dart';

enum ClosurePeriod { daily, monthly, annual }

/// Service ISCA (Inaltérabilité, Sécurisation, Conservation, Archivage).
/// Assure la conformité fiscale via un journal d'audit chaîné (Hash-chaining).
class IscalAuditService {
  final RemoteStorageService _remoteStorage;
  static const String _logCollection = 'fiscal_audit_logs';
  static const String _closureCollection = 'fiscal_closures';

  IscalAuditService(this._remoteStorage);

  /// Scelle une transaction financière (Facture payée) dans le journal d'audit.
  Future<void> sealFacture(Facture facture, {String action = 'PAYMENT_SEAL'}) async {
    // 1. Récupérer le dernier hash pour chaînage
    final logs = await _remoteStorage.getAllRaw(
      _logCollection,
      limit: 1,
    );

    final String previousHash = logs.isNotEmpty 
        ? (logs.first['currentHash'] as String? ?? '0000000000000000000000000000000000000000000000000000000000000000')
        : '0000000000000000000000000000000000000000000000000000000000000000';

    // 2. Données critiques pour le hachage ISCA
    final Map<String, dynamic> payload = {
      'factureId': facture.id,
      'amountHt': facture.montant, 
      'clientId': facture.clientId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final String payloadString = jsonEncode(payload);

    // 3. Calcul du Hash SHA-256 chaîné
    final String dataToHash = '$action|$payloadString|$previousHash';
    final String currentHash = sha256.convert(utf8.encode(dataToHash)).toString();

    // 4. Enregistrement du scellé
    await _remoteStorage.saveRaw(_logCollection, '${facture.id}_${DateTime.now().millisecondsSinceEpoch}', {
      'action': action,
      'payload': payloadString,
      'previousHash': previousHash,
      'currentHash': currentHash,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Vérifie l'intégrité de la chaîne de logs.
  Future<bool> verifyChainIntegrity() async {
    final logs = await _remoteStorage.getAllRaw(_logCollection);
    // Tri par date pour reconstruire la chaîne
    logs.sort((a, b) => (a['createdAt'] as String).compareTo(b['createdAt'] as String));

    String expectedPrevHash = '0000000000000000000000000000000000000000000000000000000000000000';

    for (final log in logs) {
      final String actualPrevHash = log['previousHash'] as String;
      if (actualPrevHash != expectedPrevHash) return false;

      final String action = log['action'] as String;
      final String payload = log['payload'] as String;
      final String currentHash = log['currentHash'] as String;

      final String dataToHash = '$action|$payload|$actualPrevHash';
      final String recalculatedHash = sha256.convert(utf8.encode(dataToHash)).toString();

      if (recalculatedHash != currentHash) return false;

      expectedPrevHash = currentHash;
    }

    return true;
  }

  /// Vérifie si une transaction appartient à une période déjà clôturée.
  Future<bool> isPeriodClosed(String companyId, DateTime date) async {
    final String dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final closures = await _remoteStorage.watchCollectionRaw(
      _closureCollection,
      queryBuilder: (dynamic q) => (q as dynamic)
          .where('companyId', isEqualTo: companyId)
          .where('periodType', isEqualTo: 'DAILY')
          .where('periodDate', isEqualTo: dayKey),
    ).first;

    return closures.isNotEmpty;
  }

  /// Génère une clôture périodique.
  Future<void> generateClosure(String companyId, ClosurePeriod periodType, DateTime date) async {
    final String periodKey = periodType == ClosurePeriod.daily 
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : periodType == ClosurePeriod.monthly 
            ? '${date.year}-${date.month.toString().padLeft(2, '0')}'
            : '${date.year}';

    // Vérifier si déjà clôturé
    if (await isPeriodClosed(companyId, date)) {
      throw Exception('Période déjà clôturée.');
    }

    // Création du scellé de clôture
    final closureId = const Uuid().v4();
    await _remoteStorage.saveRaw(_closureCollection, closureId, {
      'id': closureId,
      'companyId': companyId,
      'periodType': periodType.name.toUpperCase(),
      'periodDate': periodKey,
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'CLOSED',
    });
  }
}

final iscalAuditServiceProvider = Provider<IscalAuditService>((ref) {
  return IscalAuditService(ref.watch(multiBackendRemoteProvider));
});
