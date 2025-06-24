import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final boxProvider = Provider.family<Box, String>((ref, boxName) {
  throw UnimplementedError(); // à remplacer par futureProvider si async
});

final clientBoxProvider = FutureProvider<Box>((ref) async {
  await Hive.openBox('clients');
  return Hive.box('clients');
});
