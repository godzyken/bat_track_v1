import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../models/data/json_model.dart';
import '../../adapters/signture_converter.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser implements JsonModel {
  const AppUser._();

  const factory AppUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? company,
    @JsonKey(includeFromJson: false, includeToJson: false) String? motDePasse,
    @DateTimeIsoConverter() required DateTime createdAt,
    @NullableDateTimeIsoConverter() DateTime? appUpdatedAt,
    @Default(false) bool? appIsUpdated,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  factory AppUser.empty() => AppUser(
    uid: '',
    name: '',
    email: '',
    role: '',
    createdAt: tryParseDate('')!,
    motDePasse: '',
  );

  @override
  String get id => uid;

  @override
  bool get isUpdated => appIsUpdated!;

  @override
  DateTime? get updatedAt => appUpdatedAt;
}
