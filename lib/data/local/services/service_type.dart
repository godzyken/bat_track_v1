import '../models/index_model_extention.dart';
import 'hive_service.dart';

class ChantierService {
  static const _box = 'chantiers';

  Future<void> add(Chantier chantier, String id) =>
      HiveService.put<Chantier>(_box, chantier.id, chantier);

  Future<void> delete(String id) => HiveService.delete<Chantier>(_box, id);

  Future<List<Chantier>> getAll() => HiveService.getAll<Chantier>(_box);
}

class ClientService {
  static const _box = 'clients';

  Future<void> add(Client client) =>
      HiveService.put<Client>(_box, client.id, client);

  Future<void> delete(String id) => HiveService.delete<Client>(_box, id);

  Future<List<Client>> getAll() => HiveService.getAll<Client>(_box);
}

class TechnicienService {
  static const _box = 'techniciens';

  Future<void> add(Technicien tech) =>
      HiveService.put<Technicien>(_box, tech.id, tech);

  Future<void> delete(String id) => HiveService.delete<Technicien>(_box, id);

  Future<List<Technicien>> getAll() => HiveService.getAll<Technicien>(_box);
}

class InterventionService {
  static const _box = 'interventions';

  Future<void> add(Intervention intervention) =>
      HiveService.put<Intervention>(_box, intervention.id, intervention);

  Future<void> delete(String id) => HiveService.delete<Intervention>(_box, id);

  Future<List<Intervention>> getAll() => HiveService.getAll<Intervention>(_box);
}
