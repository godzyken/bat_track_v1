abstract class JsonModel {
  String? get id;
  JsonModel copyWithId(String? id); // à implémenter dans chaque modèle
  Map<String, dynamic> toJson();
  JsonModel fromJson(Map<String, dynamic> json);
}
