import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/json_form_controller.dart';
import '../models/adapters/json_adapter.dart';

/// ==================== PROVIDERS DIRECTS ====================

/// Provider pour Chantier Form
final chantierFormControllerProvider = StateNotifierProvider.autoDispose<
  JsonFormController,
  Map<String, dynamic>
>((ref) {
  final adapter = ChantierAdapter(); // ✅ Utilisation de ton adapter concret
  return JsonFormController(adapter);
});

/// Provider pour Projet Form
final projetFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = ProjetAdapter(); // ✅ Utilisation de ton adapter concret
        return JsonFormController(adapter);
      },
    );

/// Provider pour Client Form
final clientFormControllerProvider =
    StateNotifierProvider.autoDispose<JsonFormController, Map<String, dynamic>>(
      (ref) {
        final adapter = ClientAdapter(); // ✅ Utilisation de ton adapter concret
        return JsonFormController(adapter);
      },
    );
