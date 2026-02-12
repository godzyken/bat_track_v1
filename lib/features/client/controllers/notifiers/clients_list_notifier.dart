import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/models/entities/client_entity.dart';

class ClientListNotifier extends EntityListNotifier<Client, ClientEntity> {}

final clientListProvider =
    AsyncNotifierProvider<ClientListNotifier, List<Client>>(
      () => ClientListNotifier(),
    );
