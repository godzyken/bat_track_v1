import 'package:bat_track_v1/data/local/models/index_model_extention.dart';

/// --- Étapes du chantier Penelope ---
final etape1 = ChantierEtape(
  id: 'etp_001',
  chantierId: 'ch_001',
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
  ],
  pieces: [
    Piece(
      id: 'piece_001',
      nom: 'Fondation principale',
      surface: 120.0,
      addedBy: 'tech_001',
    ),
  ],
);

final etape2 = ChantierEtape(
  id: 'etp_002',
  chantierId: 'ch_001',
  titre: 'Installation électrique',
  description: 'Mise en place du tableau principal et câblage des pièces.',
  dateDebut: DateTime(2025, 3, 10),
  dateFin: DateTime(2025, 3, 20),
  terminee: false,
  ordre: 2,
  statut: 'en_cours',
  piecesJointes: [
    PieceJointe(
      id: 'pj_002',
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
      id: 'piece_002',
      nom: 'Tableau électrique principal',
      surface: 2.0,
      addedBy: 'tech_002',
    ),
  ],
);

final etape3 = ChantierEtape(
  id: 'etp_003',
  chantierId: 'ch_001',
  titre: 'Finitions intérieures',
  description: 'Peinture, revêtements sols et plafonds.',
  dateDebut: DateTime(2025, 4, 1),
  dateFin: DateTime(2025, 4, 15),
  terminee: false,
  ordre: 3,
  statut: 'prévu',
  piecesJointes: [
    PieceJointe(
      id: 'pj_003',
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
      id: 'piece_003',
      nom: 'Salon - Peinture blanche',
      surface: 35.0,
      addedBy: 'tech_003',
    ),
  ],
);

final etapesChantierPenelope = [etape1, etape2, etape3];

/// --- Chantier ---
final chantierPenelope = Chantier(
  id: 'ch_001',
  nom: 'Penelope',
  adresse: '12 rue de la Cuisse',
  clientId: 'cli_001',
  dateDebut: DateTime(2025, 3, 1),
  // On ajoute les étapes dans le chantier
  etapes: etapesChantierPenelope,
);

/// --- Projet ---
final projetPenelope = Projet(
  id: 'prj_001',
  nom: 'Rénovation villa Penelope',
  description:
      'Projet de rénovation complète avec mise aux normes électriques et finitions modernes.',
  createdBy: 'cli_001',
  dateDebut: DateTime(2025, 2, 20),
  chantiers: [chantierPenelope],
  dateFin: DateTime.now().add(const Duration(days: 20)),
  company: 'Panhihi',
  members: [],
  assignedUserIds: [],
  clientValide: true,
  chefDeProjetValide: true,
  techniciensValides: true,
  superUtilisateurValide: false,
  cloudVersion: const {},
  localDraft: const {},
);
