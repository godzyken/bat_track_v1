import 'package:flutter/material.dart';

import '../../data/local/models/index_model_extention.dart';
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

  /// Détails générés dynamiquement à partir de tous les champs pertinents
  String get displayDetails {
    final json = toJson();
    final buffer = StringBuffer();
    final skipKeys = {
      'nom',
      'titre',
      'email',
      'description',
      'specialite',
      'adresse',
    };

    for (final entry in json.entries) {
      if (skipKeys.contains(entry.key)) continue;

      final key = _prettifyKey(entry.key);
      final value = _formatValue(entry.value);
      if (value != null && value.length > 25) buffer.writeln('$key : $value');
    }

    return buffer.toString().trim();
  }

  /// Tags (chips) dynamiques pour les champs courts
  List<String> get displayTags {
    final json = toJson();
    return json.entries
        .where(
          (e) =>
              e.value != null &&
              (e.value is String && (e.value as String).length < 25 ||
                  e.value is num ||
                  e.value is bool),
        )
        .map((e) => '${_prettifyKey(e.key)} : ${_formatValue(e.value)}')
        .toList();
  }

  /// Icône en fonction du type
  IconData get displayIcon {
    final type = runtimeType.toString();
    return switch (type) {
      'Client' => Icons.business,
      'Technicien' => Icons.engineering,
      'Chantier' => Icons.construction,
      'Intervention' => Icons.build_circle,
      _ => Icons.info_outline,
    };
  }

  String _prettifyKey(String key) {
    // Convertit "lastInterventionDate" → "Last Intervention Date"
    final buffer = StringBuffer();
    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else if (char == char.toUpperCase() && char != '_') {
        buffer.write(' $char');
      } else if (char == '_') {
        buffer.write(' ');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  String? _formatValue(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    } else if (value is bool) {
      return value ? 'Oui' : 'Non';
    } else if (value is List) {
      return value
          .map((e) => _formatValue(e) ?? '')
          .where((s) => s.isNotEmpty)
          .join(', ');
    } else if (value is ChantierEtape) {
      return value.description;
      // } else if (value is DocumentFichier) {
      //   return '${value.type.toUpperCase()}: ${value.filename}';
    } else if (value is Map<String, dynamic>) {
      // Si c'est un document sous forme brute JSON
      if (value['type'] != null && value['filename'] != null) {
        return '${(value['type'] as String).toUpperCase()}: ${value['filename']}';
      }
      return value.keys.map((k) => '$k: ${value[k]}').join(', ');
    } else {
      return value.toString();
    }
  }
}
