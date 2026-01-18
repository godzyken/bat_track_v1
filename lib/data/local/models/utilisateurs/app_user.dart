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
  bool get isUpdated => appIsUpdated != null;

  @override
  DateTime? get updatedAt => appUpdatedAt;

  @override
  UnifiedModel copyWithId(String newId) => copyWith(uid: newId);

  @override
  // TODO: implement appIsUpdated
  bool? get appIsUpdated => throw UnimplementedError();

  @override
  // TODO: implement appUpdatedAt
  DateTime? get appUpdatedAt => throw UnimplementedError();

  @override
  // TODO: implement company
  String? get company => throw UnimplementedError();

  @override
  // TODO: implement createdAt
  DateTime get createdAt => throw UnimplementedError();

  @override
  // TODO: implement email
  String? get email => throw UnimplementedError();

  @override
  // TODO: implement instanceId
  String? get instanceId => throw UnimplementedError();

  @override
  // TODO: implement lastTimeConnect
  DateTime? get lastTimeConnect => throw UnimplementedError();

  @override
  // TODO: implement motDePasse
  String? get motDePasse => throw UnimplementedError();

  @override
  // TODO: implement name
  String? get name => throw UnimplementedError();

  @override
  // TODO: implement ownerId
  String? get ownerId => throw UnimplementedError();

  @override
  // TODO: implement role
  String get role => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement uid
  String get uid => throw UnimplementedError();
}
