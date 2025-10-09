import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
import '../../adapters/signture_converter.dart';
import '../utilisateurs/app_user.dart';

part 'equipement.freezed.dart';
part 'equipement.g.dart';

@HiveType(typeId: 31)
@freezed
class Equipement
    with _$Equipement, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Equipement._();

  const factory Equipement({
    @HiveField(0) required String id,
    @HiveField(1) required String nom,
    @HiveField(2) required String type, // extincteur, détecteur, etc.
    @HiveField(3) String? localisation,
    @HiveField(4) @DateTimeIsoConverter() required DateTime dateInstallation,
    @HiveField(5)
    @NullableDateTimeIsoConverter()
    DateTime? dateProchaineVerification,
    @HiveField(6)
    @Default(false)
    bool enService, // actif, hors service, à vérifier
    @HiveField(7) String? homologation,
    @HiveField(8) String? commentaire,
    @HiveField(9) @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @HiveField(10) required String chantierId,
    @HiveField(11) required String createdBy,
    @HiveField(12) List<String>? technicienIds,
    int? count,
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
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  bool canAccess(AppUser user) {
    if (user.isAdmin) return true;

    if (user.isTechnicien) {
      return technicienIds?.contains(user.uid) ?? false;
    }

    if (user.isClient) {
      return user.uid == createdBy;
    }

    return false;
  }

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
