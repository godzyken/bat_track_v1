import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'intervention.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class Intervention {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String chantierId;
  @HiveField(2)
  final String technicienId;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final String statut;

  Intervention({
    required this.id,
    required this.chantierId,
    required this.technicienId,
    required this.description,
    required this.date,
    required this.statut,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);
  Map<String, dynamic> toJson() => _$InterventionToJson(this);

  Map<String, dynamic> toMap() => toJson();
  factory Intervention.fromMap(Map<String, dynamic> map) =>
      Intervention.fromJson(map);

  factory Intervention.mock() => Intervention(
    id: const Uuid().v4(),
    chantierId: 'chantier_001',
    technicienId: 'technicien_001',
    date: DateTime.now(),
    statut: 'Planifiée',
    description: 'Inspection de routine',
  );
}
