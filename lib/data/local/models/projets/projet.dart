import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'projet.freezed.dart';
part 'projet.g.dart';

@freezed
class Projet with _$Projet implements JsonModel<Projet> {
  const factory Projet({
    required String id,
    required String nom,
    required String description,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @DateTimeIsoConverter() required DateTime dateFin,
    required bool clientValide,
    required bool chefDeProjetValide,
    required bool techniciensValides,
    required bool superUtilisateurValide,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
  }) = _Projet;

  factory Projet.fromJson(Map<String, dynamic> json) => _$ProjetFromJson(json);

  factory Projet.mock() => Projet(
    id: const Uuid().v4(),
    nom: 'Categate',
    description:
        'Renovation de la Structure et aggrandissement de la piece principale',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(Duration(days: 26)),
    clientValide: true,
    chefDeProjetValide: true,
    techniciensValides: true,
    superUtilisateurValide: false,
  );
}
