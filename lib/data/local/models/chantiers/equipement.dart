import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';

part 'equipement.freezed.dart';
part 'equipement.g.dart';

@HiveType(typeId: 31)
@freezed
class Equipement with _$Equipement implements JsonModel {
  const Equipement._();

  const factory Equipement({
    @HiveField(0) required String id,
    @HiveField(1) required String nom,
    @HiveField(2) required String type, // extincteur, détecteur, etc.
    @HiveField(3) String? localisation,
    @HiveField(4) DateTime? dateInstallation,
    @HiveField(5) DateTime? dateProchaineVerification,
    @HiveField(6)
    @Default(false)
    bool enService, // actif, hors service, à vérifier
    @HiveField(7) String? homologation,
    @HiveField(8) String? commentaire,
    @HiveField(9) DateTime? updatedAt,
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
  );
}
