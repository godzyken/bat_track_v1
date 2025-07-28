import 'package:bat_track_v1/data/local/models/chantiers/equipement.dart';
import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipementListNotifier extends EntityListNotifier<Equipement> {}

final equipementListProvider =
    AsyncNotifierProvider<EquipementListNotifier, List<Equipement>>(
      () => EquipementListNotifier(),
    );
