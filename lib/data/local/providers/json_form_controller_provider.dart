import 'package:bat_track_v1/models/controllers/states/form_model_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/json_form_controller.dart';

final jsonFormControllerProvider = NotifierProvider.autoDispose
    .family<
      JsonFormController<UnifiedModel>,
      FormStateModel,
      JsonFormArgs<UnifiedModel>
    >((arg) {
      final controller = JsonFormController<UnifiedModel>();
      controller.init(arg.adapter, arg.model);
      return controller;
    });
