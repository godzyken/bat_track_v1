import 'package:bat_track_v1/models/controllers/states/form_model_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../models/adapters/json_adapter.dart';

class JsonFormController<T extends UnifiedModel>
    extends Notifier<FormStateModel> {
  late JsonAdapter<T> adapter;
  late T initialModel;

  @override
  FormStateModel build() {
    return FormStateModel(values: {}, errors: {}, touched: {});
  }

  void init(JsonAdapter<T> adapter, T model) {
    this.adapter = adapter;
    this.initialModel = model;

    final values = adapter.toJson(model);

    state = FormStateModel(values: values, errors: {}, touched: {});
  }

  void updateField(String key, dynamic value) {
    final newValues = {...state.values, key: value};
    final newTouched = {...state.touched, key};

    final error = _validateField(key, value);

    final newErrors = {...state.errors, key: error};

    state = state.copyWith(
      values: newValues,
      touched: newTouched,
      errors: newErrors,
    );
  }

  // ═══════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════

  String? _validateField(String key, dynamic value) {
    final field = adapter.fields.firstWhere((f) => f.name == key);

    if (field.required) {
      if (value == null || value.toString().trim().isEmpty) {
        return 'Champ requis';
      }
    }

    if (field.validator != null) {
      return field.validator!(value);
    }

    return null;
  }

  void validateAll() {
    final errors = <String, String?>{};

    for (final field in adapter.fields) {
      final value = state.values[field.name];
      errors[field.name] = _validateField(field.name, value);
    }

    state = state.copyWith(errors: errors);
  }

  // ═══════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════

  String? getError(String field) {
    if (!state.touched.contains(field)) return null;
    return state.errors[field];
  }

  bool isTouched(String field) => state.touched.contains(field);

  bool get isValid => state.isValid;

  bool get canSubmit => state.isValid;

  bool validateRequiredFields() {
    for (final field in adapter.fields) {
      if (field.required &&
          (state.values[field.name] == null ||
              state.values[field.name].toString().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  /// Convertit l’état actuel du formulaire en modèle [T]
  T toModel() {
    validateAll();

    if (!state.isValid) {
      throw Exception('Formulaire invalide');
    }
    // Fusionne les valeurs actuelles avec les valeurs par défaut du modèle
    final merged = {...adapter.initialData, ...state.values};
    return adapter.fromJson(merged);
  }

  /// Réinitialise le formulaire
  void reset() {
    final values = adapter.toJson(initialModel);

    state = FormStateModel(values: values, errors: {}, touched: {});
  }
}

class JsonFormArgs<T extends UnifiedModel> {
  final JsonAdapter<T> adapter;
  final T model;

  JsonFormArgs({required this.adapter, required this.model});
}
