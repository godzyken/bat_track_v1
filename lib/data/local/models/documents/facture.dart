import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';
import '../base/has_acces_control.dart';
import 'facture_draft.dart';

part 'facture.freezed.dart';
part 'facture.g.dart';

@freezed
class Facture
    with _$Facture, JsonModel<Facture>
    implements JsonSerializableModel<Facture> {
  const Facture._();

  const factory Facture({
    required String id,
    required String reference,
    required double montant,
    required String clientId,
    required DateTime date,
    DateTime? updatedAt,
  }) = _Facture;

  /// Génération standard JSON via json_serializable
  factory Facture.fromJson(Map<String, dynamic> json) =>
      _$FactureFromJson(json);

  /// Création à partir d'un Draft (exemple)
  factory Facture.fromDraft(
    FactureDraft draft,
    String reference,
    String clientId,
    DateTime? updatedAt,
  ) {
    final montantTotal = draft.lignesManuelles.fold<double>(
      0,
      (previousValue, ligne) => previousValue + ligne.montant,
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
}
