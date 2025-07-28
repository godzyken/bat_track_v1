import 'package:bat_track_v1/data/local/models/chantiers/equipement.dart';
import 'package:bat_track_v1/data/local/models/entities/chantier_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/client_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/facture_draft_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/facture_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/facture_model_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/intervention_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/main_oeuvre_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/materiau_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/materiel_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/piece_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/pieces_jointes_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/projet_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/technicien_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/user_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> registerHiveAdapters() async {
  Hive.registerAdapter(ChantierEntityAdapter());
  Hive.registerAdapter(ClientEntityAdapter());
  Hive.registerAdapter(TechnicienEntityAdapter());
  Hive.registerAdapter(InterventionEntityAdapter());
  Hive.registerAdapter(PieceJointeAdapter());
  Hive.registerAdapter(PieceEntityAdapter());
  Hive.registerAdapter(MateriauEntityAdapter());
  Hive.registerAdapter(MaterielEntityAdapter());
  Hive.registerAdapter(MainOeuvreEntityAdapter());
  Hive.registerAdapter(ProjetEntityAdapter());
  Hive.registerAdapter(FactureEntityAdapter());
  Hive.registerAdapter(CustomLigneFactureEntityAdapter());
  Hive.registerAdapter(FactureDraftEntityAdapter());
  Hive.registerAdapter(FactureModelEntityAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserRoleEntityAdapter());
  Hive.registerAdapter(EquipementAdapter());
}
