import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';
import '../../adapters/signture_converter.dart';
import '../index_model_extention.dart';

part 'intervention.freezed.dart';
part 'intervention.g.dart';

@freezed
class Intervention
    with _$Intervention, JsonModel<Intervention>
    implements JsonSerializableModel<Intervention>, HasAccessControl {
  const Intervention._();

  const factory Intervention({
    required String id,
    required String chantierId,
    required String technicienId,
    required String company,
    required String description,
    @DateTimeIsoConverter() required DateTime create,
    @NullableDateTimeIsoConverter() DateTime? datePassed,
    required String statut,
    required List<PieceJointe> document,
    String? titre,
    String? commentaire,
    FactureDraft? facture,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    int? count,
  }) = _Intervention;

  factory Intervention.fromJson(Map<String, dynamic> json) =>
      _$InterventionFromJson(json);

  factory Intervention.mock() => Intervention(
    id: const Uuid().v4(),
    chantierId: 'chId_006',
    technicienId: 'tId_0056',
    company: 'Kréol',
    description: 'Depose du murre coté baie',
    create: DateTime.now(),
    statut: 'En Cours',
    document: [PieceJointe.mock(), PieceJointe.mock()],
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  bool canAccess(AppUser user) {
    if (user.isAdmin) return true;
    if (user.isTechnicien) return technicienId == user.uid;
    return user.company == company;
  }
}
