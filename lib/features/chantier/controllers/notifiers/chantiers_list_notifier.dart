import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ChantierListNotifier extends EntityListNotifier<Chantier> {}

final chantierListProvider =
    AsyncNotifierProvider<ChantierListNotifier, List<Chantier>>(
      () => ChantierListNotifier(),
    );
