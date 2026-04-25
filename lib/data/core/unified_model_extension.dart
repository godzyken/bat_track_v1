import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_models/core/models/unified_model.dart';

import '../local/models/mixin/hive_convertible.dart';

/// Mixin pour l'affichage UI générique
mixin DisplayMixin on UnifiedModel {
  String get displayTitle {
    final json = toJson();
    return json['nom'] ?? json['titre'] ?? json['id'] ?? 'Sans nom';
  }

  String get displaySubtitle {
    final json = toJson();
    return json['email'] ?? json['description'] ?? json['adresse'] ?? '';
  }

  IconData get displayIcon => Icons.info_outline;
}

/// Interface pour les entités Hive (simplifié)
abstract class HiveEntity<TModel> extends HiveObject
    implements HiveCovertible<TModel> {
  String get id;
  DateTime? get updatedAt;

  @override
  TModel toModel();
  @override
  HiveEntity<TModel> fromModel(TModel model);
}

/// Converters de dates standards
class DateTimeConverter {
  const DateTimeConverter();
  DateTime fromJson(String json) => DateTime.parse(json);
  String toJson(DateTime object) => object.toIso8601String();
}

class NullableDateTimeConverter {
  const NullableDateTimeConverter();
  DateTime? fromJson(String? json) =>
      json != null ? DateTime.tryParse(json) : null;
  String? toJson(DateTime? object) => object?.toIso8601String();
}
