import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';

part 'equipement.freezed.dart';
part 'equipement.g.dart';

@freezed
sealed class Equipement extends UnifiedModel with _$Equipement {
  Equipement._();

  factory Equipement({
    required String id,
    required String nom,
    required String type, // extincteur, détecteur, etc.
    String? localisation,
    @DateTimeIsoConverter() required DateTime dateInstallation,
    @NullableDateTimeIsoConverter() DateTime? dateProchaineVerification,
    @Default(false) bool enService, // actif, hors service, à vérifier
    String? homologation,
    String? commentaire,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    required String chantierId,
    required String createdBy,
    @Default([]) List<String>? technicienIds,
    int? count,
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
  }) = _Equipement;

  factory Equipement.fromJson(Map<String, dynamic> json) =>
      _$EquipementFromJson(json);

  factory Equipement.mock() => Equipement(
    id: const Uuid().v4(),
    nom: 'Ylea',
    type: 'Extincteur',
    localisation: '9 via del Gato en el pantalônes, Quancun, Mexico',
    dateInstallation: DateTime(18, 08, 2018),
    dateProchaineVerification: DateTime(18, 08, 2019),
    enService: true,
    homologation: '97/23/CE, EN 3-7+A1, AENOR',
    commentaire: 'Sans fluor, 6 litres 9,3 kg. 0°C à +60°C',
    updatedAt: DateTime.now(),
    chantierId: 'ch_007',
    createdBy: 'Bill Cosby',
    technicienIds: [],
    chefDeProjetValide: true,
    clientValide: true,
  );

  @override
  String? get ownerId => createdBy;

  @override
  List<String> get assignedUserIds => technicienIds ?? [];

  @override
  bool get isUpdated => updatedAt != null;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );
}
