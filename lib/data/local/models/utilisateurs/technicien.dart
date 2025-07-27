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
    DateTime? updatedAt,
  }) = _Technicien;

  factory Technicien.fromJson(Map<String, dynamic> json) =>
      _$TechnicienFromJson(json);

  /*  @override
  Technicien fromJson(Map<String, dynamic> json) => Technicien.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TechnicienToJson(this);

  @override
  Technicien copyWithId(String? id) => copyWith(id: id ?? this.id);*/

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
  );
}
