import 'package:bat_track_v1/data/local/models/projets/projet.dart';
import 'package:uuid/uuid.dart';

extension ProjetUtils on Projet {
  bool get toutesPartiesOntValide =>
      clientValide && chefDeProjetValide && techniciensValides;

  bool get estPretPourDolibarr =>
      toutesPartiesOntValide && !superUtilisateurValide;

  Projet copyWithId(String? newId) => copyWith(id: newId ?? id);

  static Projet mock() => Projet(
    id: const Uuid().v4(),
    nom: 'Construction École',
    company: 'Léon Bross',
    description: 'Projet de construction modulaire pour école primaire.',
    dateDebut: DateTime.now(),
    dateFin: DateTime.now().add(const Duration(days: 120)),
    updatedAt: DateTime.now(),
    clientValide: true,
    chefDeProjetValide: true,
    techniciensValides: true,
    superUtilisateurValide: false,
    members: [],
    createdBy: 'Nickholos',
    deadLine: DateTime(1),
    cloudVersion: {
      'nom': 'Categate',
      'description': 'Rénovation validée par admin',
    },
    localDraft: {
      'nom': 'Categate v2',
      'description': 'Rénovation avec nouvelles fenêtres',
    },
  );
}
