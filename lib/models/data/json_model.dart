import '../../data/local/models/index_model_extention.dart';

abstract class JsonModel {
  String? get id;
  JsonModel copyWithId(String? id); // à implémenter dans chaque modèle
  Map<String, dynamic> toJson();
  JsonModel fromJson(Map<String, dynamic> json);
  // fromDolibarrJson
  JsonModel fromDolibarrJson(Map<String, dynamic> json);

  static T? fromDynamic<T>(Map<String, dynamic> json) {
    switch (T) {
      case Chantier:
        return Chantier.fromJson(json) as T;
      case Client:
        return Client.fromJson(json) as T;
      case PieceJointe:
        return PieceJointe.fromJson(json) as T;
      case Materiel:
        return Materiel.fromJson(json) as T;
      case Materiau:
        return Materiau.fromJson(json) as T;
      case MainOeuvre:
        return MainOeuvre.fromJson(json) as T;
      // ajoute ici les autres modèles
      case Technicien:
        return Technicien.fromJson(json) as T;
      case Intervention:
        return Intervention.fromJson(json) as T;
      case ChantierEtape:
        return ChantierEtape.fromJson(json) as T;
      case Piece:
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

abstract class JsonModelWithUrl extends JsonModel {
  String? get firebaseUrl;
  JsonModelWithUrl copyWith({String? firebaseUrl});
}

extension JsonModelFactory on JsonModel {
  static T? fromDynamic<T>(Map<String, dynamic> json) {
    switch (T) {
      case Chantier:
        return Chantier.fromJson(json) as T;
      case Client:
        return Client.fromJson(json) as T;
      case PieceJointe:
        return PieceJointe.fromJson(json) as T;
      // ajoute ici les autres modèle
      case Materiel:
        return Materiel.fromJson(json) as T;
      case Materiau:
        return Materiau.fromJson(json) as T;
      case MainOeuvre:
        return MainOeuvre.fromJson(json) as T;
      case Technicien:
        return Technicien.fromJson(json) as T;
      case Intervention:
        return Intervention.fromJson(json) as T;
      case ChantierEtape:
        return ChantierEtape.fromJson(json) as T;
      case Piece:
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
