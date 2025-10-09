import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/unified_model.dart';
import '../../adapters/signture_converter.dart';

part 'main_oeuvre.freezed.dart';
part 'main_oeuvre.g.dart';

@freezed
class MainOeuvre
    with _$MainOeuvre, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const MainOeuvre._();

  const factory MainOeuvre({
    required String id,
    required String chantierId,
    required String idTechnicien,
    required double heuresEstimees,
    @DateTimeIsoConverter() required DateTime dateDebut,
    @NullableDateTimeIsoConverter() DateTime? passedTime,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
    @Default(false) bool isActive,
  }) = _MainOeuvre;

  /// JSON local
  @override
  factory MainOeuvre.fromJson(Map<String, dynamic> json) =>
      _$MainOeuvreFromJson(json);

  factory MainOeuvre.mock() => MainOeuvre(
    id: 'moId_0012',
    chantierId: 'ch_023',
    idTechnicien: 'tec_0023',
    heuresEstimees: 35,
    dateDebut: DateTime.now(),
    isActive: true,
  );

  @override
  bool get isUpdated => updatedAt != null;

  @override
  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);
}
