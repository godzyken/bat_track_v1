import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/json_form_controller.dart';
import '../models/adapters/json_adapter.dart';

final jsonFormControllerProvider = StateNotifierProvider.autoDispose
    .family<JsonFormController, Map<String, dynamic>, JsonAdapter>(
      (ref, adapter) => JsonFormController(adapter),
    );
