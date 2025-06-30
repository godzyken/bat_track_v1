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
final chantierEtapeBoxProvider = Provider(
  (ref) async => await Hive.openBox<ChantierEtape>('chantierEtapes'),
);
final pieceJointeBoxProvider = Provider<Box<PieceJointe>>(
  (ref) => Hive.box<PieceJointe>('piecesJointes'),
);

final chantierProvider = Provider.family<Chantier?, String>((ref, id) {
  final box = Hive.box<Chantier>('chantiers');
  return box.get(id);
});

final clientProvider = Provider.family<Client?, String>((ref, id) {
  final box = Hive.box<Client>('clients');
  return box.get(id);
});

final technicienProvider = Provider.family<Technicien?, String>((ref, id) {
  final box = Hive.box<Technicien>('techniciens');
  return box.get(id);
});

final interventionProvider = Provider.family<Intervention?, String>((ref, id) {
  final box = Hive.box<Intervention>('interventions');
  return box.get(id);
});

final chantierEtapesProvider =
    FutureProvider.family<List<ChantierEtape>, String>((ref, chantierId) async {
      final box = await ref.watch(chantierEtapeBoxProvider);
      return box.values.where((e) => e.id == chantierId).toList();
    });

final pieceJointeProvider = Provider.family<PieceJointe?, String>((ref, id) {
  final box = Hive.box<PieceJointe>('piecesJointes');
  return box.get(id);
});

final chantierServiceProvider = Provider<EntityService<Chantier>>(
  (ref) => const EntityService('chantiers'),
);

final clientServiceProvider = Provider<EntityService<Client>>(
  (ref) => const EntityService('clients'),
);

final technicienServiceProvider = Provider<EntityService<Technicien>>(
  (ref) => const EntityService('techniciens'),
);

final interventionServiceProvider = Provider<EntityService<Intervention>>(
  (ref) => const EntityService('interventions'),
);

final chantierEtapeServiceProvider = Provider<EntityService<ChantierEtape>>(
  (ref) => const EntityService('chantierEtapes'),
);

final pieceJointeServiceProvider = Provider<EntityService<PieceJointe>>(
  (ref) => const EntityService('piecesJointes'),
);
