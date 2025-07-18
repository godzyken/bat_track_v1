import '../../data/local/models/index_model_extention.dart';

abstract class JsonModel<T> {
  String? get id;

  static T? fromDynamic<T>(Map<String, dynamic> json) {
    switch (T) {
      case Chantier _:
        return Chantier.fromJson(json) as T;
      case Client _:
        return Client.fromJson(json) as T;
      case PieceJointe _:
        return PieceJointe.fromJson(json) as T;
      case Materiel _:
        return Materiel.fromJson(json) as T;
      case Materiau _:
        return Materiau.fromJson(json) as T;
      case MainOeuvre _:
        return MainOeuvre.fromJson(json) as T;
      // ajoute ici les autres modèles
      case Technicien _:
        return Technicien.fromJson(json) as T;
      case Intervention _:
        return Intervention.fromJson(json) as T;
      case ChantierEtape _:
        return ChantierEtape.fromJson(json) as T;
      case Piece _:
        return Piece.fromJson(json) as T;
      /*      case Facture:
        return Facture.fromJson(json) as T;
      case Projet:
        return Projet.fromJson(json) as T;*/
      default:
        return null;
    }
  }

  T? copyWithId(String? id); // à implémenter dans chaque modèle
  Map<String, dynamic> toJson();

  T? fromJson(Map<String, dynamic> json);

  // fromDolibarrJson
  T? fromDolibarrJson(Map<String, dynamic> json);
}

abstract class JsonModelWithUrl extends JsonModel {
  String? get firebaseUrl;

  JsonModelWithUrl copyWith({String? firebaseUrl});
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
      /*      case Facture:
        return Facture.fromJson(json) as T;
      case Projet:
        return Projet.fromJson(json) as T;*/
      default:
        return null;
    }
  }
}
