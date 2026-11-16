import 'dart:io';

import 'package:bat_track_v1/data/local/models/entities/app_user_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/chantier_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/chantier_etapes_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/client_entity.dart';
import 'package:bat_track_v1/data/local/models/entities/equipement_entity.dart';
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
import 'package:bat_track_v1/models/data/maperror/log_entry_hive.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp
        .createTemp('hive_test_')
        .then((dir) => dir.path);
  }
}

class HiveTestSetup {
  static Future<void> setupHive() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    final tempDir = await Directory.systemTemp.createTemp('hive_test_');
    await Hive.initFlutter(tempDir.path);

    _registerAdapterSafely(AppUserEntityAdapter());
    _registerAdapterSafely(ChantierEntityAdapter());
    _registerAdapterSafely(ChantierEtapesEntityAdapter());
    _registerAdapterSafely(ClientEntityAdapter());
    _registerAdapterSafely(CustomLigneFactureEntityAdapter());
    _registerAdapterSafely(EquipementEntityAdapter());
    _registerAdapterSafely(FactureDraftEntityAdapter());
    _registerAdapterSafely(FactureEntityAdapter());
    _registerAdapterSafely(FactureModelEntityAdapter());
    _registerAdapterSafely(FactureStatusEntityAdapter());
    _registerAdapterSafely(InterventionEntityAdapter());
    _registerAdapterSafely(LogEntryHiveAdapter());
    _registerAdapterSafely(MainOeuvreEntityAdapter());
    _registerAdapterSafely(MateriauEntityAdapter());
    _registerAdapterSafely(MaterielEntityAdapter());
    _registerAdapterSafely(PieceEntityAdapter());
    _registerAdapterSafely(PieceJointeEntityAdapter());
    _registerAdapterSafely(ProjetEntityAdapter());
    _registerAdapterSafely(TechnicienEntityAdapter());
    _registerAdapterSafely(UserEntityAdapter());
    _registerAdapterSafely(UserRoleEntityAdapter());
  }

  static void _registerAdapterSafely<T>(TypeAdapter<T> adapter) {
    try {
      Hive.registerAdapter(adapter, override: true);
    } catch (_) {}
  }

  static Future<void> tearDownHive() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  }

  static Future<Box<T>> openTestBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<T>(name).close();
    }
    return await Hive.openBox<T>(name);
  }
}
