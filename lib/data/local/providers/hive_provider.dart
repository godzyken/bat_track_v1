import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/index_model_extention.dart';
import '../services/hive_service.dart';
import '../services/service_type.dart';

final hiveInitProvider = FutureProvider<void>((ref) async {
  await HiveService.init();
});

final chantierBoxProvider = Provider<Box<Chantier>>(
  (ref) => Hive.box<Chantier>('chantiers'),
);
final clientBoxProvider = Provider<Box<Client>>(
  (ref) => Hive.box<Client>('clients'),
);
final technicienBoxProvider = Provider<Box<Technicien>>(
  (ref) => Hive.box<Technicien>('techniciens'),
);
final interventionBoxProvider = Provider<Box<Intervention>>(
  (ref) => Hive.box<Intervention>('interventions'),
);

final chantierServiceProvider = Provider<ChantierService>(
  (ref) => ChantierService(),
);
final clientServiceProvider = Provider<ClientService>((ref) => ClientService());
final technicienServiceProvider = Provider<TechnicienService>(
  (ref) => TechnicienService(),
);
final interventionServiceProvider = Provider<InterventionService>(
  (ref) => InterventionService(),
);
