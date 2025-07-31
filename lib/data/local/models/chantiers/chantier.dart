import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../adapters/signture_converter.dart';

part 'chantier.freezed.dart';
part 'chantier.g.dart';

@freezed
class Chantier
    with _$Chantier, JsonModel<Chantier>, JsonSerializableModel<Chantier> {
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

  factory Chantier.fromJson(Map<String, dynamic> json) =>
      _$ChantierFromJson(json);

  factory Chantier.mock() => Chantier(
    id: const Uuid().v4(),
    nom: 'Villa Categate',
    adresse: '2T allée du pont levis',
    clientId: 'clId_009',
    dateDebut: DateTime.now(),
  );

  @override
  bool get isUpdated => updatedAt != null;
}
