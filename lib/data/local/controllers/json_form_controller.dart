import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../models/adapters/json_adapter.dart';

class JsonFormController<T extends UnifiedModel>
    extends Notifier<Map<String, dynamic>> {
  late JsonAdapter<T> adapter;
  late T initialModel;

  @override
  Map<String, dynamic> build() {
    return adapter.toJson(initialModel);
  }

  void init(JsonAdapter<T> adapter, T model) {
    this.adapter = adapter;
    this.initialModel = model;

    state = adapter.toJson(model);
  }

  void updateField(String key, dynamic value) {
    state = {...state, key: value};
  }

  bool validateRequiredFields() {
    for (final field in adapter.fields) {
      if (field.required &&
          (state[field.name] == null || state[field.name].toString().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// Convertit l’état actuel du formulaire en modèle [T]
  T toModel() {
    // Fusionne les valeurs actuelles avec les valeurs par défaut du modèle
    final merged = {...adapter.initialData, ...state};
    return adapter.fromJson(merged);
  }

  /// Réinitialise le formulaire
  void reset() {
    state = adapter.initialData ?? {};
  }
}
