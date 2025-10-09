import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:uuid/uuid.dart';

class MockDataFactories {
  static const _uuid = Uuid();

  static Projet createProjet({
    String? id,
    String? nom,
    String? createdBy,
    ProjetStatus? status,
    List<String>? members,
    List<Chantier>? chantiers,
  }) {
    return Projet(
      id: id ?? _uuid.v4(),
      nom: nom ?? 'Projet Test ${DateTime.now().millisecondsSinceEpoch}',
      description: 'Description test',
      dateDebut: DateTime.now(),
      dateFin: DateTime.now().add(const Duration(days: 30)),
      company: 'Test Company',
      createdBy: createdBy ?? 'user_test',
      members: members ?? [],
      assignedUserIds: [],
      status: status ?? ProjetStatus.draft,
      clientValide: false,
      chefDeProjetValide: false,
      techniciensValides: false,
      superUtilisateurValide: false,
      cloudVersion: const {},
      localDraft: const {},
      chantiers: chantiers,
    );
  }

  static List<Projet> createProjetList(int count) {
    return List.generate(
      count,
      (index) => createProjet(nom: 'Projet $index', id: 'proj_$index'),
    );
  }

  static Chantier createChantier({String? id, String? projetId, String? nom}) {
    return Chantier(
      id: id ?? _uuid.v4(),
      chefDeProjetId: projetId ?? 'proj_default',
      nom: nom ?? 'Chantier Test',
      adresse: '7 rue du Solitaires',
      dateDebut: DateTime.now(),
      clientId: 'client_test',
    );
  }

  static AppUser createUser({
    String? uid,
    UserRole? role,
    bool isAdmin = false,
  }) {
    return AppUser(
      uid: uid ?? _uuid.v4(),
      email: 'test@example.com',
      role: isAdmin ? 'admin' : 'technicien',
      createdAt: DateTime.now(),
      name: 'anthony',
    );
  }
}
