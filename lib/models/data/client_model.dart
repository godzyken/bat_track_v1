import 'json_model.dart';

class Client extends JsonModel {
  @override
  final String? id;
  final String nom;
  final String? email;

  Client({this.id, required this.nom, this.email});

  @override
  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'email': email};

  @override
  Client fromJson(Map<String, dynamic> json) =>
      Client(id: json['id'], nom: json['nom'], email: json['email']);

  @override
  Client copyWithId(String? id) => Client(id: id, nom: nom, email: email);
}
