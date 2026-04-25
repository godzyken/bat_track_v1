import 'package:flutter/material.dart';
import 'package:shared_models/core/models/unified_model.dart';

import '../index_model_extention.dart';

/// Interface unifiée pour les formulaires dynamiques et la sérialisation JSON
abstract class JsonAdapter<T extends UnifiedModel> {
  /// Retourne un `Map<String, dynamic>` pour construire un formulaire
  Map<String, dynamic> toJson(T model);

  /// Construit un modèle métier à partir d’un JSON
  T fromJson(Map<String, dynamic> json);

  /// Liste des champs utilisés pour construire un formulaire dynamique
  List<JsonField> get fields;

  /// Données initiales du formulaire (par défaut : vide)
  Map<String, dynamic> get initialData => {};
}

enum FieldType {
  text,
  number,
  date,
  select,
  multiSelect,
  checkbox,
  switcher,
  image,
  file,
  textarea,
  hidden,
  custom,
}

/// Représente un champ d’un formulaire dynamique
class JsonField {
  final String name;
  final String label;
  final IconData icon;
  final FieldType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? options;

  /// Permet de charger dynamiquement les options (par exemple depuis Firestore)
  final Future<List<String>> Function()? asyncOptions;

  /// Indique si le champ est en lecture seule
  final bool readOnly;

  /// Indique si le champ est visible
  final bool visible;

  /// Placeholder (texte d’aide)
  final String? hint;

  /// Fonction de validation personnalisée
  final String? Function(dynamic value)? validator;

  const JsonField({
    required this.name,
    required this.label,
    required this.type,
    required this.icon,
    this.required = false,
    this.defaultValue,
    this.options,
    this.asyncOptions,
    this.readOnly = false,
    this.visible = true,
    this.hint,
    this.validator,
  });

  /// Renvoie `true` si ce champ est une liste d’options
  bool get isSelectable =>
      type == FieldType.select || type == FieldType.multiSelect;

  /// Crée une copie modifiée
  JsonField copyWith({
    String? name,
    String? label,
    FieldType? type,
    IconData? icon,
    bool? required,
    List<String>? options,
    Future<List<String>> Function()? asyncOptions,
    dynamic defaultValue,
    bool? readOnly,
    bool? visible,
    String? hint,
    String? Function(dynamic value)? validator,
  }) {
    return JsonField(
      name: name ?? this.name,
      label: label ?? this.label,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      required: required ?? this.required,
      options: options ?? this.options,
      asyncOptions: asyncOptions ?? this.asyncOptions,
      defaultValue: defaultValue ?? this.defaultValue,
      readOnly: readOnly ?? this.readOnly,
      visible: visible ?? this.visible,
      hint: hint ?? this.hint,
      validator: validator ?? this.validator,
    );
  }
}

/// Implémentation concrète pour Chantier
class ChantierAdapter extends JsonAdapter<Chantier> {
  final Map<String, dynamic> _initialData;

  ChantierAdapter({Map<String, dynamic>? initialData})
    : _initialData = initialData ?? {};

  @override
  Chantier fromJson(Map<String, dynamic> json) => Chantier.fromJson(json);

  @override
  Map<String, dynamic> toJson(Chantier model) => model.toJson();

  @override
  Map<String, dynamic> get initialData => _initialData;

  @override
  // TODO: implement fields
  List<JsonField> get fields => throw UnimplementedError();
}

/// 🧩 Classe générique qui remplace ChantierAdapter, ProjetAdapter, etc.
class GenericJsonAdapter<T extends UnifiedModel> extends JsonAdapter<T> {
  final T Function(Map<String, dynamic> json) fromJsonFn;
  final Map<String, dynamic> Function(T model) toJsonFn;
  final List<JsonField> Function()? buildFields;
  final Map<String, dynamic> _initialData;

  GenericJsonAdapter({
    required this.fromJsonFn,
    required this.toJsonFn,
    this.buildFields,
    Map<String, dynamic>? initialData,
  }) : _initialData = initialData ?? {};

  @override
  T fromJson(Map<String, dynamic> json) => fromJsonFn(json);

  @override
  Map<String, dynamic> toJson(T model) => toJsonFn(model);

  @override
  List<JsonField> get fields => buildFields?.call() ?? const [];

  @override
  Map<String, dynamic> get initialData => _initialData;
}
