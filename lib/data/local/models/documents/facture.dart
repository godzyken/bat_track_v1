import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';
import 'facture_draft.dart';

part 'facture.freezed.dart';
part 'facture.g.dart';

@freezed
class Facture extends UnifiedModel with _$Facture {
  const Facture._();

  const factory Facture({
    required String id,
    required String reference,
    required double montant,
    required String clientId,
    required DateTime date,
    DateTime? updatedAt,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,
    @Default(false) bool isCloudOnly,
  }) = _Facture;

  factory Facture.fromJson(Map<String, dynamic> json) =>
      _$FactureFromJson(json);

  factory Facture.fromDraft(
    FactureDraft draft,
    String reference,
    String clientId,
    DateTime? updatedAt,
  ) {
    final montantTotal = draft.lignesManuelles.fold<double>(
      0,
      (prev, ligne) => prev + ligne.montant,
    );
    return Facture(
      id: const Uuid().v4(),
      reference: reference,
      montant: montantTotal,
      clientId: clientId,
      date: DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Facture.mock() => Facture(
    id: const Uuid().v4(),
    reference: 'reference',
    montant: 2340,
    clientId: 'clientId',
    date: DateTime.now(),
  );

  // ─── UnifiedModel ─────────────────────────────────────────────
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get isUpdated => updatedAt != null;

  // ─── AccessControlMixin (seul getter abstrait) ────────────────
  @override
  String? get ownerId => clientId;

  // ─── ValidationMixin (toutesPartiesOntValide override) ────────
  // Les getters clientValide, chefDeProjetValide, etc. sont déjà
  // dans le constructeur freezed — ils surchargent les défauts du mixin.
  // toutesPartiesOntValide est recalculé ici pour utiliser ValidationHelper.
  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );
}
