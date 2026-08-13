import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

final boxProvider = Provider.family<Box<dynamic>, String>((ref, boxName) {
  throw UnimplementedError(); // à remplacer par futureProvider si async
});
