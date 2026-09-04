import 'package:bat_track_v1/data/local/models/extensions/budget_extentions.dart';
import '../documents/pieces_jointes.dart';
import 'chantier_etapes.dart';
import 'intervention.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../base/import_log.dart';

part 'chantier.freezed.dart';
part 'chantier.g.dart';

@freezed
abstract class Chantier extends UnifiedModel with _$Chantier {
  Chantier._();

  factory Chantier({
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
    @NullableDateTimeIsoConverter() DateTime? deletedAt,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,
    @Default(false) bool isCloudOnly,
    @Default(false) bool isDeleted,
    double? remiseParDefaut, // Ajout
    @Default(20.0) double tauxTVAParDefaut, // Ajout (ex: 20%)
  }) = _Chantier;

  /// Génération JSON
  factory Chantier.fromJson(Map<String, dynamic> json) =>
      _$ChantierFromJson(json);

  @override
  List<String> get assignedUserIds => technicienIds;

  @override
  bool canRead(AppUser user) => true;

  @override
  bool canEdit(AppUser user) =>
      AppUserAccessControl(user).isAdmin || chefDeProjetId == user.uid;

  @override
  bool canDelete(AppUser user) => AppUserAccessControl(user).isAdmin;

  @override
  bool canMerge(AppUser user) => AppUserAccessControl(user).isAdmin;

  @override
  bool canValidate(AppUser user) =>
      AppUserAccessControl(user).isAdmin || chefDeProjetId == user.uid;

  /// Mock
  factory Chantier.mock() => Chantier(
    id: const Uuid().v4(),
    nom: 'Villa Categate',
    adresse: '2T allée du pont levis',
    clientId: 'clId_009',
    dateDebut: DateTime.now(),
  );

  /// 🔹 Getters concrets pour les mixins
  @override
  String? get ownerId => chefDeProjetId;

  @override
  bool get isUpdated => updatedAt != null;

  /// 🔹 Copier avec nouvel ID
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  /// 🔹 Méthode de parsing sécurisé si besoin
  factory Chantier.fromJsonSafe(Map<String, dynamic> json, {ImportLog? log}) {
    try {
      return Chantier(
        id: (json['id'] as String?) ?? const Uuid().v4(),
        nom: (json['nom'] as String?) ?? 'Chantier sans nom',
        adresse: (json['adresse'] as String?) ?? '',
        clientId: (json['clientId'] as String?) ?? '',
        dateDebut:
            tryParseDate(
              json['dateDebut'],
              fallback: DateTime.now(),
              context: 'Chantier.dateDebut',
            ) ??
            DateTime.now(),
        dateFin: tryParseDate(
          json['dateFin'],
          fallback: DateTime.now(),
          context: 'Chantier.dateFin',
        ),
        updatedAt: tryParseDate(
          json['updatedAt'],
          fallback: DateTime.now(),
          context: 'Chantier.updatedAt',
        ),
        etat: json['etat'] as String?,
        technicienIds: List<String>.from((json['technicienIds'] as Iterable?) ?? []),
        documents: [], // parser si nécessaire
        etapes: [], // parser si nécessaire
        commentaire: json['commentaire'] as String?,
        budgetPrevu: (json['budgetPrevu'] is num)
            ? (json['budgetPrevu'] as num).toDouble()
            : null,
        budgetReel: (json['budgetReel'] is num)
            ? (json['budgetReel'] as num).toDouble()
            : null,
        interventions: [],
        chefDeProjetId: json['chefDeProjetId'] as String?,
        clientValide: json['clientValide'] == true,
        chefDeProjetValide: json['chefDeProjetValide'] == true,
        techniciensValides: json['techniciensValides'] == true,
        superUtilisateurValide: json['superUtilisateurValide'] == true,
        isCloudOnly: json['isCloudOnly'] == true,
      );
    } catch (e) {
      log?.addError('Erreur de parsing Chantier: $e');
      rethrow;
    }
  }

  /// Vérifie si toutes les parties ont validé ce chantier
  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );

  /// 🔹 Méthode de suppression
  /// Marquer l'entité comme supprimée
  /// @param date La date de suppression
  /// @return Une copie de l'entité avec la date de suppression mise à jour
  @override
  Chantier markDeleted(DateTime date) {
    return copyWith(deletedAt: date, updatedAt: date);
  }
}
