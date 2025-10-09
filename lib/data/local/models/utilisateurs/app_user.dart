import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/unified_model.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser
    with _$AppUser, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const AppUser._();

  const factory AppUser({
    required String uid,
    required String role,
    String? name,
    String? email,
    String? company,
    @JsonKey(includeFromJson: false, includeToJson: false) String? motDePasse,
    @DateTimeIsoConverter() required DateTime createdAt,
    @NullableDateTimeIsoConverter() DateTime? appUpdatedAt,
    @Default(false) bool? appIsUpdated,
    String? instanceId,
    DateTime? updatedAt,
    DateTime? lastTimeConnect,
  }) = _AppUser;

  @override
  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  factory AppUser.empty() => AppUser(
    uid: 'guest',
    name: 'Visiteur',
    email: null,
    role: 'guest',
    createdAt: tryParseDate('')!,
    company: null,
  );

  @override
  String get id => uid;

  @override
  bool get isUpdated => appIsUpdated!;

  @override
  DateTime? get updatedAt => appUpdatedAt;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(uid: newId);
}
