import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';
import '../index_model_extention.dart';

part 'intervention.freezed.dart';
part 'intervention.g.dart';

@freezed
class Intervention
    with
        _$Intervention,
        JsonModel<Intervention>,
        JsonSerializableModel<Intervention> {
  const factory Intervention({
    required String id,
    required String chantierId,
    required String technicienId,
    required String description,
    required DateTime date,
    required String statut,
    required List<PieceJointe> document,
    String? titre,
    String? commentaire,
    FactureDraft? facture,
    DateTime? updatedAt,
  }) = _Intervention;

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);

  /*  @override
  Intervention? fromJson(Map<String, dynamic> json) =>
      Intervention.fromJson(json);*/

  /*  @override
  Map<String, dynamic> toJson() => _$InterventionToJson(this);*/

  /*  @override
  Intervention copyWithId(String? id) => copyWith(id: id ?? this.id);*/

  factory Intervention.mock() => Intervention(
    id: const Uuid().v4(),
    chantierId: 'chId_006',
    technicienId: 'tId_0056',
    description: 'Depose du murre coté baie',
    date: DateTime.now(),
    statut: 'En Cours',
    document: [PieceJointe.mock(), PieceJointe.mock()],
  );
}
