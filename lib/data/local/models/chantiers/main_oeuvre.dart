import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_oeuvre.freezed.dart';
part 'main_oeuvre.g.dart';

@freezed
class MainOeuvre
    with
        _$MainOeuvre,
        JsonModel<MainOeuvre>,
        JsonSerializableModel<MainOeuvre> {
  const factory MainOeuvre({
    required String id,
    String? idTechnicien,
    required double heuresEstimees,
    DateTime? updatedAt,
  }) = _MainOeuvre;

  /// JSON local
  factory MainOeuvre.fromJson(Map<String, dynamic> json) =>
      _$MainOeuvreFromJson(json);

  /*  @override
  MainOeuvre fromJson(Map<String, dynamic> json) => MainOeuvre.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MainOeuvreToJson(this);

  @override
  MainOeuvre copyWithId(String? id) => copyWith(id: id ?? this.id);*/

  factory MainOeuvre.mock() => MainOeuvre(id: 'moId_0012', heuresEstimees: 35);
}
