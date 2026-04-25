import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/json_form_controller.dart';
import '../models/adapters/json_adapter.dart';

/// ==================== PROVIDERS DIRECTS ====================

/// Provider pour Chantier Form
final chantierFormControllerProvider =
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      JsonFormController.new,
    );

/// Provider pour Projet Form
final projetFormControllerProvider =
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      JsonFormController.new,
    );

/// Provider pour Client Form
final clientFormControllerProvider =
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      JsonFormController.new,
    );

/// Provider pour Technicien Form
final technicienFormControllerProvider =
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>((
      ref,
      model,
    ) {
      final adapter = GenericJsonAdapter<Technicien>(
        fromJsonFn: Technicien.fromJson,
        toJsonFn: (model) => model.toJson(),
      );
      return JsonFormController(adapter);
    });

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
