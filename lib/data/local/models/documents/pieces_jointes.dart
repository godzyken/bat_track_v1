import 'dart:io';
import 'dart:typed_data';

import 'package:bat_track_v1/data/local/adapters/signture_converter.dart';
import 'package:bat_track_v1/data/local/models/base/has_files.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/data/json_model.dart';

part 'pieces_jointes.freezed.dart';
part 'pieces_jointes.g.dart';

@freezed
class PieceJointe
    with _$PieceJointe
    implements
        JsonModel<PieceJointe>,
        JsonSerializableModel<PieceJointe>,
        HasFile {
  const PieceJointe._();

  const factory PieceJointe({
    required String id,
    required String nom,
    required String url,
    required String typeMime,
    @DateTimeIsoConverter() required DateTime createdAt,
    required String type,
    required String parentType,
    required String parentId,
    required double taille,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,
  }) = _PieceJointe;

  factory PieceJointe.fromJson(Map<String, dynamic> json) =>
      _$PieceJointeFromJson(json);

  factory PieceJointe.mock({
    String? id,
    String? nom,
    String? url,
    String? type,
    String? parentType,
    String? parentId,
    String? typeMime,
    DateTime? createAt,
    double? taille,
    DateTime? updatedAt,
  }) {
    return PieceJointe(
      id: id ?? const Uuid().v4(),
      nom: nom ?? 'document.pdf',
      url: url ?? 'https://example.com/document.pdf',
      type: type ?? 'facture',
      taille: taille ?? 1024,
      createdAt: createAt ?? DateTime.now(),
      parentType: parentType ?? "Chantier",
      parentId: parentId ?? "ch_01",
      typeMime: typeMime ?? "application/pdf",
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  File getFile() => File(url);

  @override
  bool get isUpdated => updatedAt != null;
}

// Extension personnalisée
extension PieceJointeX on PieceJointe {
  File getFile() {
    return File(url);
  }

  Uint8List getUintList() => Uint8List(taille.toInt());
}
