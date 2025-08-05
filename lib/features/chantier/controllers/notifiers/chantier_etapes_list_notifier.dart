import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ChantierEtapesListNotifier extends EntityListNotifier<ChantierEtape> {}

final chantierEtapesListProvider =
    AsyncNotifierProvider<ChantierEtapesListNotifier, List<ChantierEtape>>(
      () => ChantierEtapesListNotifier(),
    );
