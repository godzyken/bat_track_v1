import 'package:bat_track_v1/data/local/models/base/has_acces_control.dart';
import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/unified_model.dart';
import '../extensions/budget_extentions.dart';

part 'projet.freezed.dart';
part 'projet.g.dart';

enum ProjetStatus { draft, pendingValidation, validated, rejected }

@freezed
class Projet
    with _$Projet, AccessControlMixin, ValidationMixin
    implements UnifiedModel {
  const Projet._();

  const factory Projet({
    required String id,
    required String nom,
    required String description,

    @DateTimeIsoConverter() required DateTime dateDebut,
    @DateTimeIsoConverter() required DateTime dateFin,
    @NullableDateTimeIsoConverter() DateTime? deadLine,
    @NullableDateTimeIsoConverter() DateTime? updatedAt,

    /// Entreprise associée
    required String company,

    /// UID du créateur (client propriétaire)
    required String createdBy,

    /// Membres liés (techs assignés, collaborateurs)
    required List<String> members,

    /// Techniciens affectés explicitement
    @Default([]) List<String> assignedUserIds,

    /// État du projet (workflow)
    @Default(ProjetStatus.draft) ProjetStatus status,

    /// Validations explicites
    @Default(false) bool clientValide,
    @Default(false) bool chefDeProjetValide,
    @Default(false) bool techniciensValides,
    @Default(false) bool superUtilisateurValide,

    /// Gestion des versions
    required Map<String, dynamic> cloudVersion,
    Map<String, dynamic>? localDraft,
    String? specialite,
    String? localisation,
    double? budgetEstime,
    String? currentUserId,
    List<Chantier>? chantiers,
  }) = _Projet;

  /// JSON
  factory Projet.fromJson(Map<String, dynamic> json) => _$ProjetFromJson(json);

  /// Mock
  factory Projet.mock() => Projet(
    id: const Uuid().v4(),
    nom: 'Categate',
    description:
        'Renovation de la Structure et aggrandissement de la piece principale',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(Duration(days: 26)),
    clientValide: true,
    chefDeProjetValide: true,
    techniciensValides: true,
    superUtilisateurValide: false,
    updatedAt: DateTime.now(),
    createdBy: 'Penelope',
    members: [],
    assignedUserIds: [],
    status: ProjetStatus.draft,
    deadLine: DateTime.now().add(Duration(days: 365)),
    company: 'Bouygues',
    cloudVersion: {
      'nom': 'Categate',
      'description': 'Rénovation validée par admin',
    },
    localDraft: {
      'nom': 'Categate v2',
      'description': 'Rénovation avec nouvelles fenêtres',
    },
    currentUserId: 'um1',
    chantiers: [],
  );

  /// 🔹 Getters concrets pour les mixins
  @override
  String get ownerId => createdBy;

  @override
  bool get isUpdated => updatedAt != null;

  bool get toutesPartiesValide => ValidationHelper.computeValidationStatus(
    clientValide: clientValide,
    chefDeProjetValide: chefDeProjetValide,
    techniciensValides: techniciensValides,
    superUtilisateurValide: superUtilisateurValide,
  );

  @override
  UnifiedModel copyWithId(String newId) => copyWith(id: newId);

  bool get isDraft => status == ProjetStatus.draft;

  /// Droits
  bool canValidate(AppUser user) => user.isAdmin;
  bool canAssignTech(AppUser user) => user.isAdmin || user.isChefDeProjet;
  bool canMergeToCloud(AppUser user) => user.isAdmin || user.isChefDeProjet;
  bool canEditUser(AppUser user, Projet projet) {
    if (user.isAdmin) return true;
    if (user.isClient &&
        projet.createdBy == user.uid &&
        projet.status == ProjetStatus.draft) {
      return true;
    }
    if (user.isTechnicien && projet.members.contains(user.uid)) return true;
    return false;
  }

  @override
  // TODO: implement budgetEstime
  double? get budgetEstime => throw UnimplementedError();

  @override
  // TODO: implement chantiers
  List<Chantier>? get chantiers => throw UnimplementedError();

  @override
  // TODO: implement cloudVersion
  Map<String, dynamic> get cloudVersion => throw UnimplementedError();

  @override
  // TODO: implement company
  String get company => throw UnimplementedError();

  @override
  // TODO: implement createdBy
  String get createdBy => throw UnimplementedError();

  @override
  // TODO: implement currentUserId
  String? get currentUserId => throw UnimplementedError();

  @override
  // TODO: implement dateDebut
  DateTime get dateDebut => throw UnimplementedError();

  @override
  // TODO: implement dateFin
  DateTime get dateFin => throw UnimplementedError();

  @override
  // TODO: implement deadLine
  DateTime? get deadLine => throw UnimplementedError();

  @override
  // TODO: implement description
  String get description => throw UnimplementedError();

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();

  @override
  // TODO: implement localDraft
  Map<String, dynamic>? get localDraft => throw UnimplementedError();

  @override
  // TODO: implement localisation
  String? get localisation => throw UnimplementedError();

  @override
  // TODO: implement members
  List<String> get members => throw UnimplementedError();

  @override
  // TODO: implement nom
  String get nom => throw UnimplementedError();

  @override
  // TODO: implement specialite
  String? get specialite => throw UnimplementedError();

  @override
  // TODO: implement status
  ProjetStatus get status => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement updatedAt
  DateTime? get updatedAt => throw UnimplementedError();
}
