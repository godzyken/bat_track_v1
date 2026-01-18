import 'package:bat_track_v1/hive_registrar.g.dart';
import 'package:hive_ce/hive.dart';

void setupHive() {
  Hive.registerAdapters();
}
