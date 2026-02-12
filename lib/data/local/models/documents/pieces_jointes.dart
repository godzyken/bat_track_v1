import 'dart:io';
import 'dart:typed_data';

import 'package:bat_track_v1/data/local/models/base/has_files.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

import '../extensions/budget_extentions.dart';

part 'pieces_jointes.freezed.dart';
part 'pieces_jointes.g.dart';

@freezed
class PieceJointe
    with _$PieceJointe, AccessControlMixin, ValidationMixin
    implements UnifiedModel, HasFile {
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
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    @Default(false) bool isCloudOnly,
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

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  @override
  bool get toutesPartiesOntValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );

  @override
  // TODO: implement chefDeProjetValide
  bool get chefDeProjetValide => throw UnimplementedError();

  @override
  // TODO: implement clientValide
  bool get clientValide => throw UnimplementedError();

  @override
  // TODO: implement createdAt
  DateTime get createdAt => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement isCloudOnly
  bool get isCloudOnly => throw UnimplementedError();

  @override
  // TODO: implement nom
  String get nom => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String? get ownerId => throw UnimplementedError();

  @override
  // TODO: implement parentId
  String get parentId => throw UnimplementedError();

  @override
  // TODO: implement parentType
  String get parentType => throw UnimplementedError();

  @override
  // TODO: implement superUtilisateurValide
  bool get superUtilisateurValide => throw UnimplementedError();

  @override
  // TODO: implement taille
  double get taille => throw UnimplementedError();

  @override
  // TODO: implement techniciensValides
  bool get techniciensValides => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  String get type => throw UnimplementedError();

  @override
  // TODO: implement typeMime
  String get typeMime => throw UnimplementedError();

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();

  @override
  // TODO: implement url
  String get url => throw UnimplementedError();
}

// Extension personnalisée
extension PieceJointeX on PieceJointe {
  File getFile() {
    return File(url);
  }

  Uint8List getUintList() => Uint8List(taille.toInt());
}
