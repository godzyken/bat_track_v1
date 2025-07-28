import '../../data/local/models/index_model_extention.dart';

mixin JsonModel<T> {
  String get id;

  DateTime? get updatedAt;
}

mixin JsonSerializableModel<T> on JsonModel<T> {
  static T? copyWithId<T>(String? id) => throw UnimplementedError();

  Map<String, dynamic> toJson();

  static T? fromJson<T>(Map<String, dynamic> json) =>
      throw UnimplementedError();
}

mixin class Serializable {
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

abstract class JsonModelWithUrl implements JsonModel {
  String? get firebaseUrl;

  JsonModelWithUrl copyWith({String? firebaseUrl});
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
  static T? fromDynamic<T>(Map<String, dynamic> json) {
    switch (T) {
      case Chantier _:
        return Chantier.fromJson(json) as T;
      case Client _:
        return Client.fromJson(json) as T;
      case PieceJointe _:
        return PieceJointe.fromJson(json) as T;
      // ajoute ici les autres modèle
      case Materiel _:
        return Materiel.fromJson(json) as T;
      case Materiau _:
        return Materiau.fromJson(json) as T;
      case MainOeuvre _:
        return MainOeuvre.fromJson(json) as T;
      case Technicien _:
        return Technicien.fromJson(json) as T;
      case Intervention _:
        return Intervention.fromJson(json) as T;
      case ChantierEtape _:
        return ChantierEtape.fromJson(json) as T;
      case Piece _:
        return Piece.fromJson(json) as T;
      case Facture _:
        return Facture.fromJson(json) as T;
      case FactureDraft _:
        return FactureDraft.fromJson(json) as T;
      case FactureModel _:
        return FactureModel.fromJson(json) as T;
      case Projet _:
        return Projet.fromJson(json) as T;
      case UserModel _:
        return UserModel.fromJson(json) as T;
      default:
        return null;
    }
  }

  T createEmptyEntity<T extends JsonModel>(String id) {
    final model = JsonModelFactory.fromDynamic<T>({'id': id});
    if (model == null) {
      throw Exception('Impossible de créer une instance vide pour $T');
    }
    return model.copyWithId(id)!;
  }
}

extension JsonModelExtension<T> on JsonModel<T> {
  bool get isUpdated => updatedAt != null;
}
