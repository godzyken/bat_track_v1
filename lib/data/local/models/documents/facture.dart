import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';
import 'facture_draft.dart';

part 'facture.freezed.dart';
part 'facture.g.dart';

@freezed
sealed class Facture extends UnifiedModel with _$Facture {
  Facture._();

  factory Facture({
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

  /// Génération standard JSON via json_serializable
  @override
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

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get isUpdated => updatedAt != null;

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );

  @override
  // TODO: implement chefDeProjetValide
  bool get chefDeProjetValide => throw UnimplementedError();

  @override
  // TODO: implement clientId
  String get clientId => throw UnimplementedError();

  @override
  // TODO: implement clientValide
  bool get clientValide => throw UnimplementedError();

  @override
  // TODO: implement date
  DateTime get date => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement montant
  double get montant => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String? get ownerId => throw UnimplementedError();

  @override
  // TODO: implement reference
  String get reference => throw UnimplementedError();

  @override
  // TODO: implement superUtilisateurValide
  bool get superUtilisateurValide => throw UnimplementedError();

  @override
  // TODO: implement techniciensValides
  bool get techniciensValides => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}
