import '../../data/local/models/index_model_extention.dart';

mixin JsonModel<T> {
  String get id;

  DateTime? get updatedAt;

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  static DateTime parseDateTimeNonNull(dynamic value) {
    final result = parseDateTime(value);
    if (result == null) {
      throw FormatException('Date invalide : $value');
    }
    return result;
  }

  static String? toJsonDateTime(DateTime? date) => date?.toIso8601String();

  static T empty<T>() => throw UnimplementedError('empty<T> not impl.');

  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  /// Méthode utilitaire : true si updatedAt est non nul
  bool get isUpdated => updatedAt != null;
}

mixin class Serializable {
  Map<String, dynamic> toJson() =>
      throw UnimplementedError('toJson() non implémenté');
}

abstract class JsonModelWithUrl implements JsonModel {
  String? get firebaseUrl;

  JsonModelWithUrl copyWith({String? firebaseUrl});
}

abstract class JsonModelWithUser<T> implements JsonModel<T> {
  String get ownerId;
  String? get currentUserId;
  List<String> get assignedUserIds; // Ex: techs assignés

  JsonModelWithUser copyWith({
    String? id,
    String? ownerId,
    String? currentUserId,
    List<String>? assignedUserIds,
  });
}

extension JsonModelCopyWith<T> on JsonModel<T> {
  T copyWithId(String newId) {
    if (this is Chantier) return (this as Chantier).copyWith(id: newId) as T;
    if (this is Client) return (this as Client).copyWith(id: newId) as T;
    if (this is PieceJointe) {
      return (this as PieceJointe).copyWith(id: newId) as T;
    }
    if (this is Materiel) return (this as Materiel).copyWith(id: newId) as T;
    if (this is Materiau) return (this as Materiau).copyWith(id: newId) as T;
    if (this is MainOeuvre) {
      return (this as MainOeuvre).copyWith(id: newId) as T;
    }
    if (this is Technicien) {
      return (this as Technicien).copyWith(id: newId) as T;
    }
    if (this is Intervention) {
      return (this as Intervention).copyWith(id: newId) as T;
    }
    if (this is ChantierEtape) {
      return (this as ChantierEtape).copyWith(id: newId) as T;
    }
    if (this is Piece) return (this as Piece).copyWith(id: newId) as T;
    if (this is Facture) {
      return (this as Facture).copyWith(id: newId) as T;
    }
    if (this is FactureDraft) {
      return (this as FactureDraft).copyWith(factureId: newId) as T;
    }
    if (this is FactureModel) {
      return (this as FactureModel).copyWith(id: newId) as T;
    }
    if (this is Projet) return (this as Projet).copyWith(id: newId) as T;
    if (this is UserModel) return (this as UserModel).copyWith(id: newId) as T;

    throw UnimplementedError('copyWithId non implémenté pour $T');
  }
}

extension JsonModelFactory on JsonModel {
  static final Map<String, dynamic Function(Map<String, dynamic>)> _builders =
      {};

  /// À appeler au boot de ton application pour chaque modèle :
  /// [`JsonModelFactory.register<Projet>((json) => Projet.fromJson`](json));
  static void register<T>(T Function(Map<String, dynamic>) builder) {
    _builders[T.toString()] = builder;
  }

  /// Retourne null si aucun builder enregistré pour T
  static T? fromDynamic<T>(Map<String, dynamic> json) {
    final key = T.toString();
    final builder = _builders[key] as T Function(Map<String, dynamic>)?;
    if (builder == null) return null;
    return builder(json);
  }

  /// Comme above mais lance si absent (optionnel)
  static T fromDynamicOrThrow<T>(Map<String, dynamic> json) {
    final maybe = fromDynamic<T>(json);
    if (maybe == null) throw Exception('No JsonModelFactory registered for $T');
    return maybe;
  }

  /*
  static T fromDynamic<T>(dynamic data) {
    if (data is T) return data;
    if (data is! Map<String, dynamic>) {
      throw ArgumentError('Donnée non valide pour fromDynamic<$T>: $data');
    }

    final map = Map<String, dynamic>.from(data);

    switch (T) {
      case Chantier _:
        return Chantier.fromJson(map) as T;
      case Client _:
        return Client.fromJson(map) as T;
      case PieceJointe _:
        return PieceJointe.fromJson(map) as T;
      case Materiel _:
        return Materiel.fromJson(map) as T;
      case Materiau _:
        return Materiau.fromJson(map) as T;
      case MainOeuvre _:
        return MainOeuvre.fromJson(map) as T;
      case Technicien _:
        return Technicien.fromJson(map) as T;
      case Intervention _:
        return Intervention.fromJson(map) as T;
      case ChantierEtape _:
        return ChantierEtape.fromJson(map) as T;
      case Piece _:
        return Piece.fromJson(map) as T;
      case Facture _:
        return Facture.fromJson(map) as T;
      case FactureDraft _:
        return FactureDraft.fromJson(map) as T;
      case FactureModel _:
        return FactureModel.fromJson(map) as T;
      case Projet _:
        return Projet.fromJson(map) as T;
      case UserModel _:
        return UserModel.fromJson(map) as T;
      default:
        throw UnimplementedError('fromDynamic non implémenté pour $T');
    }
  }
*/

  static T createEmptyEntity<T extends JsonModel>(String id) {
    final empty = fromDynamic<T>({'id': id});
    return empty?.copyWithId(id) as T;
  }
}

extension JsonModelExtension<T> on JsonModel<T> {
  bool get isUpdated => updatedAt != null;
}
