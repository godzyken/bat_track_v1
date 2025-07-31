import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'technicien.freezed.dart';
part 'technicien.g.dart';

@freezed
class Technicien
    with
        _$Technicien,
        JsonModel<Technicien>,
        JsonSerializableModel<Technicien> {
  const Technicien._();

  const factory Technicien({
    required String id,
    required String nom,
    required String email,
    required List<String> competences,
    required String specialite,
    required bool disponible,
    String? localisation,
    required double tauxHoraire,
    required List<String> chantiersAffectees,
    required List<String> etapesAffectees,
    @DateTimeIsoConverter() required DateTime createdAt,
    @NullableDateTimeIsoConverter() DateTime? dateDelete,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
  }) = _Technicien;

  factory Technicien.fromJson(Map<String, dynamic> json) =>
      _$TechnicienFromJson(json);

  factory Technicien.mock() => Technicien(
    id: const Uuid().v4(),
    nom: 'Doeuf john',
    email: 'john.doeuf@mailto.fr',
    competences: ['Soudure electro/cuivre', 'Peinture interrieur'],
    specialite: 'Plomberie',
    disponible: true,
    tauxHoraire: 13.85,
    chantiersAffectees: ['chId_0004', 'chId_0023'],
    etapesAffectees: ['etape_Salle de bain', 'etape_Cuisine'],
    createdAt: DateTime.now(),
  );

  @override
  bool get isUpdated => updatedAt != null;
}
