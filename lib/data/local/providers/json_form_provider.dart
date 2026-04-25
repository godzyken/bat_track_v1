import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/json_form_controller.dart';

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
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      JsonFormController.new,
    );

/// Provider pour ChantierEtape Form
final chantierEtapeFormControllerProvider =
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      JsonFormController.new,
    );

/// Provider pour Intervention Form
final interventionFormControllerProvider =
    NotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      JsonFormController.new,
    );
