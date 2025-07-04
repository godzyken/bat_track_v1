import 'package:hive_flutter/hive_flutter.dart';

import '../models/index_model_extention.dart';

Future<void> registerHiveAdapters() async {
  Hive.registerAdapter(ChantierAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(TechnicienAdapter());
  Hive.registerAdapter(InterventionAdapter());
  Hive.registerAdapter(ChantierEtapeAdapter());
  Hive.registerAdapter(PieceJointeAdapter());
  Hive.registerAdapter(PieceAdapter());
  Hive.registerAdapter(MateriauAdapter());
  Hive.registerAdapter(MaterielAdapter());
  Hive.registerAdapter(MainOeuvreAdapter());
}
