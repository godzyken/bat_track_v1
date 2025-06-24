import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

final hiveInitProvider = Provider<Future<void>>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
});
