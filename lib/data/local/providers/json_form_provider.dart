import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/json_form_controller.dart';
import '../models/adapters/json_adapter.dart';

/// ==================== PROVIDERS DIRECTS ====================

/// Provider pour Chantier Form
final chantierFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = GenericJsonAdapter<Chantier>(
          fromJsonFn: Chantier.fromJson,
          toJsonFn: (model) => model.toJson(),
        );
        return JsonFormController(adapter);
      },
    );

/// Provider pour Projet Form
final projetFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = GenericJsonAdapter<Projet>(
          fromJsonFn: Projet.fromJson,
          toJsonFn: (model) => model.toJson(),
        );
        return JsonFormController(adapter);
      },
    );

/// Provider pour Client Form
final clientFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = GenericJsonAdapter<Client>(
          fromJsonFn: Client.fromJson,
          toJsonFn: (model) => model.toJson(),
        );
        return JsonFormController(adapter);
      },
    );

/// Provider pour Technicien Form
final technicienFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = GenericJsonAdapter<Technicien>(
          fromJsonFn: Technicien.fromJson,
          toJsonFn: (model) => model.toJson(),
        );
        return JsonFormController(adapter);
      },
    );

/// Provider pour ChantierEtape Form
final chantierEtapeFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = GenericJsonAdapter<ChantierEtape>(
          fromJsonFn: ChantierEtape.fromJson,
          toJsonFn: (model) => model.toJson(),
        );
        return JsonFormController(adapter);
      },
    );

/// Provider pour Intervention Form
final interventionFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = GenericJsonAdapter<Intervention>(
          fromJsonFn: Intervention.fromJson,
          toJsonFn: (model) => model.toJson(),
        );
        return JsonFormController(adapter);
      },
    );
