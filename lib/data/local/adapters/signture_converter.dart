import 'package:json_annotation/json_annotation.dart';

enum EtatChantier { enCours, termine, suspendu }

class EtatChantierConverter implements JsonConverter<EtatChantier, String> {
  const EtatChantierConverter();

  @override
  EtatChantier fromJson(String json) => EtatChantier.values.firstWhere(
    (e) => e.name == json,
    orElse: () => EtatChantier.enCours,
  );

  @override
  String toJson(EtatChantier object) => object.name;
}
