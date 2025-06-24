import 'package:hive_flutter/hive_flutter.dart';

import '../models/chantier.dart';
import '../models/client.dart';
import '../models/intervention.dart';
import '../models/technicien.dart';

Future<void> registerHiveAdapters() async {
  Hive.registerAdapter(ChantierAdapter());
  Hive.registerAdapter(ClientAdapter());
  Hive.registerAdapter(TechnicienAdapter());
  Hive.registerAdapter(InterventionAdapter());
}
