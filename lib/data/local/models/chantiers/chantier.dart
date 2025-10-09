import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
import '../../adapters/signture_converter.dart' hide tryParseDate;
import '../base/import_log.dart';

part 'chantier.freezed.dart';
part 'chantier.g.dart';

@freezed
class Chantier
    with _$Chantier, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Chantier._();

  const factory Chantier({
    required String id,
    required String nom,
    required String adresse,
    required String clientId,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @NullableDateTimeIsoConverter() DateTime? dateFin,
    String? etat,
    @Default([]) List<String> technicienIds,
    @Default([]) List<PieceJointe> documents,
    @Default([]) List<ChantierEtape> etapes,
    String? commentaire,
    double? budgetPrevu,
    double? budgetReel,
    @Default([]) List<Intervention> interventions,
    String? chefDeProjetId,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,
    @Default(false) bool isCloudOnly,
  }) = _Chantier;

  @override
  factory Chantier.fromJson(Map<String, dynamic> json) =>
      _$ChantierFromJson(json);

  factory Chantier.mock() => Chantier(
    id: const Uuid().v4(),
    nom: 'Villa Categate',
    adresse: '2T allée du pont levis',
    clientId: 'clId_009',
    dateDebut: DateTime.now(),
  );

  factory Chantier.fromJsonSafe(Map<String, dynamic> json, {ImportLog? log}) {
    try {
      return Chantier(
        id: json['id'] ?? const Uuid().v4(),
        nom: json['nom'] ?? 'Chantier sans nom',
        adresse: json['adresse'] ?? '',
        clientId: json['clientId'] ?? '',
        dateDebut:
            tryParseDate(
              json['dateDebut'],
              log: log,
              context: 'Chantier.dateDebut',
            ) ??
            DateTime.now(),
        dateFin: tryParseDate(
          json['dateFin'],
          log: log,
          context: 'Chantier.dateFin',
        ),
        updatedAt: tryParseDate(
          json['updatedAt'],
          log: log,
          context: 'Chantier.updatedAt',
        ),
        etat: json['etat'],
        technicienIds: List<String>.from(json['technicienIds'] ?? []),
        documents: [],
        // à parser si nécessaire
        etapes: [],
        // à parser si nécessaire
        commentaire: json['commentaire'],
        budgetPrevu:
            (json['budgetPrevu'] is num)
                ? (json['budgetPrevu'] as num).toDouble()
                : null,
        budgetReel:
            (json['budgetReel'] is num)
                ? (json['budgetReel'] as num).toDouble()
                : null,
        interventions: [],
        chefDeProjetId: json['chefDeProjetId'],
        clientValide: json['clientValide'] ?? false,
        chefDeProjetValide: json['chefDeProjetValide'] ?? false,
        techniciensValides: json['techniciensValides'] ?? false,
        superUtilisateurValide: json['superUtilisateurValide'] ?? false,
        isCloudOnly: json['isCloudOnly'] ?? false,
      );
    } catch (e) {
      log?.addError('Erreur de parsing Chantier: $e');
      rethrow;
    }
  }

  @override
  bool get isUpdated => updatedAt != null;

  @override
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
