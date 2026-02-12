import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:shared_models/shared_models.dart';

/// Projets :
final projetA = Projet(
  id: '1',
  nom: 'Projet A',
  description: '',
  dateDebut: DateTime.now(),
  dateFin: DateTime.now().add(const Duration(days: 10)),
  company: '',
  createdBy: '',
  members: [],
  clientValide: true,
  chefDeProjetValide: true,
  techniciensValides: true,
  superUtilisateurValide: false,
  cloudVersion: const {},
  localDraft: const {},
);

final projetB = Projet(
  id: '2',
  nom: 'Projet B',
  description: '',
  dateDebut: DateTime.now(),
  dateFin: DateTime.now().add(const Duration(days: 20)),
  company: '',
  createdBy: '',
  members: [],
  clientValide: true,
  chefDeProjetValide: true,
  techniciensValides: true,
  superUtilisateurValide: false,
  cloudVersion: const {},
  localDraft: const {},
);

final projetC = Projet(
  id: '3',
  nom: 'Projet C',
  description: '',
  dateDebut: DateTime.now(),
  dateFin: DateTime.now().add(const Duration(days: 30)),
  company: '',
  createdBy: '',
  members: [],
  clientValide: true,
  chefDeProjetValide: true,
  techniciensValides: true,
  superUtilisateurValide: false,
  cloudVersion: const {},
  localDraft: const {},
);

final projetD = Projet(
  id: '4',
  nom: 'Projet D',
  description: '',
  dateDebut: DateTime.now(),
  dateFin: DateTime.now().add(const Duration(days: 40)),
  company: '',
  createdBy: '',
  members: [],
  clientValide: true,
  chefDeProjetValide: true,
  techniciensValides: true,
  superUtilisateurValide: false,
  cloudVersion: const {},
  localDraft: const {},
);

final projetE = Projet(
  id: '5',
  nom: 'Projet E',
  description: '',
  dateDebut: DateTime.now(),
  dateFin: DateTime.now().add(const Duration(days: 50)),
  company: '',
  createdBy: '',
  members: [],
  clientValide: true,
  chefDeProjetValide: true,
  techniciensValides: true,
  superUtilisateurValide: false,
  cloudVersion: const {},
  localDraft: const {},
);

/// Clients :
final client1 = Client(
  id: 'cli_001',
  nom: 'Jean Dupont',
  email: 'jean.dupont@example.com',
  telephone: '+33 6 12 34 56 78',
  adresse: '12 rue des Lilas, 34000 Montpellier',
  interventionsCount: 5,
  lastInterventionDate: DateTime(2025, 3, 2),
  status: 'actif',
  priority: 'haute',
);

final client2 = Client(
  id: 'cli_002',
  nom: 'Société Alpha BTP',
  email: 'contact@alphabtp.fr',
  telephone: '+33 4 67 22 33 44',
  adresse: 'Zone Industrielle, 34500 Béziers',
  interventionsCount: 2,
  lastInterventionDate: DateTime(2025, 2, 15),
  status: 'inactif',
  priority: 'moyenne',
);

final client3 = Client(
  id: 'cli_003',
  nom: 'Marie Martin',
  email: 'marie.martin@example.com',
  telephone: '+33 6 99 88 77 66',
  adresse: '25 avenue de la Liberté, 31000 Toulouse',
  interventionsCount: 8,
  lastInterventionDate: DateTime(2025, 3, 20),
  status: 'actif',
  priority: 'critique',
);

/// Chantiers :
final chantier1 = Chantier(
  id: '01',
  nom: 'Penelope',
  adresse: '12 rue de la Cuisse',
  clientId: 'cli_001',
  dateDebut: DateTime(2025, 1, 1),
);

final chantier2 = Chantier(
  id: '02',
  nom: 'Apollo',
  adresse: '5 avenue des Étoiles',
  clientId: 'cli_002',
  dateDebut: DateTime(2025, 2, 15),
);

final chantier3 = Chantier(
  id: '03',
  nom: 'Hermes',
  adresse: '42 boulevard du Vent',
  clientId: 'cli_003',
  dateDebut: DateTime(2025, 3, 10),
);

final chantier4 = Chantier(
  id: '04',
  nom: 'Athena',
  adresse: '77 rue de la Sagesse',
  clientId: 'cli_004',
  dateDebut: DateTime(2025, 4, 20),
);

final chantier5 = Chantier(
  id: '05',
  nom: 'Zeus',
  adresse: '1 place de l’Olympe',
  clientId: 'cli_005',
  dateDebut: DateTime(2025, 5, 5),
);

/// Etapes:
/// Étape 1 : Préparation du terrain
final etape1 = ChantierEtape(
  id: 'etp_001',
  chantierId: '01',
  titre: 'Préparation du terrain',
  description: 'Nivellement du terrain et coulage des fondations.',
  dateDebut: DateTime(2025, 3, 1),
  dateFin: DateTime(2025, 3, 5),
  terminee: true,
  ordre: 1,
  statut: 'terminée',
  piecesJointes: [
    PieceJointe(
      id: 'pj_001',
      nom: 'plan_fondations.pdf',
      url: 'https://exemple.com/docs/plan_fondations.pdf',
      typeMime: 'application/pdf',
      createdAt: DateTime(2025, 3, 1),
      type: 'document',
      parentType: 'etape',
      parentId: 'etp_001',
      taille: 245678,
    ),
    PieceJointe(
      id: 'pj_002',
      nom: 'photo_terrain.jpg',
      url: 'https://exemple.com/images/photo_terrain.jpg',
      typeMime: 'image/jpeg',
      createdAt: DateTime(2025, 3, 2),
      type: 'image',
      parentType: 'etape',
      parentId: 'etp_001',
      taille: 524367,
    ),
  ],
  pieces: [
    Piece(
      id: 'piece_001',
      nom: 'Fondation principale',
      surface: 120.0,
      addedBy: 'tech_001',
    ),
    Piece(
      id: 'piece_002',
      nom: 'Mur porteur Nord',
      surface: 45.0,
      addedBy: 'tech_002',
    ),
  ],
);

/// Étape 2 : Installation électrique
final etape2 = ChantierEtape(
  id: 'etp_002',
  chantierId: '01',
  titre: 'Installation électrique',
  description: 'Mise en place du tableau principal et câblage des pièces.',
  dateDebut: DateTime(2025, 3, 10),
  dateFin: DateTime(2025, 3, 20),
  terminee: false,
  ordre: 2,
  statut: 'en_cours',
  piecesJointes: [
    PieceJointe(
      id: 'pj_003',
      nom: 'schema_electrique.png',
      url: 'https://exemple.com/images/schema_electrique.png',
      typeMime: 'image/png',
      createdAt: DateTime(2025, 3, 10),
      type: 'image',
      parentType: 'etape',
      parentId: 'etp_002',
      taille: 198765,
    ),
  ],
  pieces: [
    Piece(
      id: 'piece_003',
      nom: 'Tableau électrique principal',
      surface: 2.0,
      addedBy: 'tech_003',
    ),
    Piece(
      id: 'piece_004',
      nom: 'Câblage étage',
      surface: 60.0,
      addedBy: 'tech_004',
    ),
  ],
);

/// Étape 3 : Finitions intérieures
final etape3 = ChantierEtape(
  id: 'etp_003',
  chantierId: '01',
  titre: 'Finitions intérieures',
  description: 'Peinture, revêtements sols et plafonds.',
  dateDebut: DateTime(2025, 4, 1),
  dateFin: DateTime(2025, 4, 15),
  terminee: false,
  ordre: 3,
  statut: 'prévu',
  piecesJointes: [
    PieceJointe(
      id: 'pj_004',
      nom: 'catalogue_peintures.pdf',
      url: 'https://exemple.com/docs/catalogue_peintures.pdf',
      typeMime: 'application/pdf',
      createdAt: DateTime(2025, 3, 25),
      type: 'document',
      parentType: 'etape',
      parentId: 'etp_003',
      taille: 345678,
    ),
  ],
  pieces: [
    Piece(
      id: 'piece_005',
      nom: 'Salon - Peinture blanche',
      surface: 35.0,
      addedBy: 'tech_005',
    ),
    Piece(
      id: 'piece_006',
      nom: 'Chambre - Parquet flottant',
      surface: 20.0,
      addedBy: 'tech_006',
    ),
  ],
);

/// Liste des étapes du chantier Penelope
final etapesChantierPenelope = [etape1, etape2, etape3];

/// AppUsers :
final appUser1 = AppUser(
  uid: 'u1',
  name: 'Alice Martin',
  email: 'alice@example.com',
  role: 'admin',
  createdAt: DateTime(2025, 1, 1),
);

final appUser2 = AppUser(
  uid: 'u2',
  name: 'Eva Morel',
  email: 'eva@example.com',
  role: 'client',
  createdAt: DateTime(2025, 2, 20),
);

final appUser3 = AppUser(
  uid: 'u3',
  name: 'Claire Dubois',
  email: 'claire@example.com',
  role: 'technicien',
  createdAt: DateTime(2025, 3, 5),
);

/// UserModels :
final userModel1 = UserModel(
  id: 'um1',
  name: 'David Leroy',
  email: 'david@example.com',
  role: UserRole.chefDeProjet,
  createAt: DateTime(2025, 1, 15),
);

final userModel2 = UserModel(
  id: 'um2',
  name: 'Eva Morel',
  email: 'eva@example.com',
  role: UserRole.client,
  createAt: DateTime(2025, 2, 20),
);

final userModel3 = UserModel(
  id: 'um3',
  name: 'Charles Xavier',
  email: 'xmen@example.com',
  role: UserRole.superUtilisateur,
  createAt: DateTime(2025, 2, 10),
);

final userModel4 = UserModel(
  id: 'um2',
  name: 'Charles Xavier',
  email: 'zoomen@example.com',
  role: UserRole.technicien,
  createAt: DateTime(2025, 2, 10),
);

final userModel5 = UserModel(
  id: 'um4',
  name: 'Roc de Quinn',
  email: 'manyteeth@example.com',
  role: UserRole.technicien,
  createAt: DateTime(2025, 2, 10),
);

/// Techniciens :
final tech1 = Technicien(
  id: 't1',
  nom: 'François Durand',
  email: 'francois@example.com',
  competences: ['électricité', 'domotique'],
  specialite: 'installations électriques',
  disponible: true,
  tauxHoraire: 45.0,
  chantiersAffectees: ['01', '03'],
  etapesAffectees: ['et1', 'et2'],
  createdAt: DateTime(2025, 1, 12),
);

final tech2 = Technicien(
  id: 't2',
  nom: 'Sophie Bernard',
  email: 'sophie@example.com',
  competences: ['peinture', 'isolation'],
  specialite: 'finition murs/plafonds',
  disponible: false,
  tauxHoraire: 38.0,
  chantiersAffectees: ['02'],
  etapesAffectees: ['et3'],
  createdAt: DateTime(2025, 2, 8),
);

/// Interventions :
final intervention1 = Intervention(
  id: 'i1',
  chantierId: '01',
  technicienId: 't1',
  company: 'BatServices',
  description: 'Installation du tableau électrique principal',
  create: DateTime(2025, 3, 1),
  statut: 'en_cours',
  document: [
    PieceJointe(
      id: 'pj1',
      nom: 'Plan Tableau Électrique',
      url: 'https://example.com/docs/tab_elec_plan.pdf',
      typeMime: 'application/pdf',
      createdAt: DateTime(2025, 3, 1),
      type: 'plan',
      parentType: 'intervention',
      parentId: 'i1',
      taille: 250000, // ~250 Ko
    ),
    PieceJointe(
      id: 'pj2',
      nom: 'Photo Installation',
      url: 'https://example.com/images/installec.jpg',
      typeMime: 'image/jpeg',
      createdAt: DateTime(2025, 3, 2),
      type: 'photo',
      parentType: 'intervention',
      parentId: 'i1',
      taille: 480000, // ~480 Ko
    ),
  ],
);

final intervention2 = Intervention(
  id: 'i2',
  chantierId: '02',
  technicienId: 't2',
  company: 'BatServices',
  description: 'Peinture des plafonds',
  create: DateTime(2025, 3, 10),
  statut: 'prévu',
  document: [
    PieceJointe(
      id: 'pj3',
      nom: 'Devis Peinture',
      url: 'https://example.com/docs/devis_peinture.pdf',
      typeMime: 'application/pdf',
      createdAt: DateTime(2025, 3, 10),
      type: 'devis',
      parentType: 'intervention',
      parentId: 'i2',
      taille: 120000,
    ),
  ],
);
