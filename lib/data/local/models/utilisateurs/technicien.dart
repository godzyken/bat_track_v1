import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';

part 'technicien.freezed.dart';
part 'technicien.g.dart';

@freezed
class Technicien
    with _$Technicien, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Technicien._();

  const factory Technicien({
    required String id,
    required String nom,
    required String email,
    required List<String> competences,
    required String specialite,
    required bool disponible,
    String? localisation,
    String? region, // Nouvelle info pour filtrage géographique
    required double tauxHoraire,
    required List<String> chantiersAffectees,
    required List<String> etapesAffectees,
    @DateTimeIsoConverter() required DateTime createdAt,
    @NullableDateTimeIsoConverter() DateTime? dateDelete,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    List<String>? realisations,
    double? rating, // note moyenne
    List<String>? metiers, // pour suggestion selon secteur métier
  }) = _Technicien;

  @override
  factory Technicien.fromJson(Map<String, dynamic> json) =>
      _$TechnicienFromJson(json);

  factory Technicien.mock() => Technicien(
    id: const Uuid().v4(),
    nom: 'Doeuf John',
    email: 'john.doeuf@example.com',
    competences: ['Soudure', 'Peinture intérieure'],
    specialite: 'Plomberie',
    disponible: true,
    tauxHoraire: 13.85,
    chantiersAffectees: ['chId_0004', 'chId_0023'],
    etapesAffectees: ['etape_Salle de bain', 'etape_Cuisine'],
    createdAt: DateTime.now(),
    region: 'Montpellier',
    rating: 4.2,
    metiers: ['plomberie', 'chauffage', 'électricité'],
    realisations: ['Projet A', 'Projet B'],
  );

  @override
  bool get isUpdated => updatedAt != null;

  /// Vérifie si le technicien est disponible pour un projet
  bool isAvailableForProjet({
    required String projetSpecialite,
    required String projetRegion,
    double? minRating = 3.5,
  }) {
    final matchesSpecialite =
        specialite.toLowerCase() == projetSpecialite.toLowerCase();
    final matchesRegion = region == null || region == projetRegion;
    final meetsRating = rating == null || rating! >= (minRating ?? 3.5);
    return disponible && matchesSpecialite && matchesRegion && meetsRating;
  }

  /// Assigne ce technicien à un projet
  Technicien assignToProjet(String projetId) {
    if (chantiersAffectees.contains(projetId)) return this;
    return copyWith(
      chantiersAffectees: [...chantiersAffectees, projetId],
      updatedAt: DateTime.now(),
    );
  }

  @override
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
