import 'package:flutter/material.dart';

import 'json_model.dart';

extension JsonModelDisplay on JsonModel {
  /// Renvoie le champ principal pour le titre (ex: nom, titre…)
  String get displayTitle {
    final json = toJson();
    return json['nom'] ?? json['titre'] ?? json['id']?.toString() ?? toString();
  }

  /// Renvoie un champ secondaire utile (email, description, adresse…)
  String get displaySubtitle {
    final json = toJson();
    return json['email'] ??
        json['specialite'] ??
        json['description'] ??
        json['adresse'] ??
        '';
  }

  /// Renvoie une icône en fonction du type
  IconData get displayIcon {
    final type = runtimeType.toString();
    return switch (type) {
      'Client' => Icons.business,
      'Technicien' => Icons.engineering,
      'Chantier' => Icons.construction,
      'Intervention' => Icons.build_circle,
      _ => Icons.info,
    };
  }
}
