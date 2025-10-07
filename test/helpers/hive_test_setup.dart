import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

    // Enregistrer tes adaptateurs Hive ici
    // await registerHiveAdapters();
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
