import 'package:hive_flutter/adapters.dart';

import '../adapters/hive_adapters.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await registerHiveAdapters();
  }

  // Ouvre la box typée et la met en cache (pour éviter réouverture)
  static final Map<String, Box> _boxes = {};

  static Future<Box<T>> _openBox<T>(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      return _boxes[boxName]! as Box<T>;
    }
    final box = await Hive.openBox<T>(boxName);
    _boxes[boxName] = box;
    return box;
  }

  // CREATE / UPDATE (put avec clé)
  static Future<void> put<T>(String boxName, String key, T object) async {
    final box = await _openBox<T>(boxName);
    await box.put(key, object);
  }

  // CREATE (ajoute sans clé, auto incrément)
  static Future<int> add<T>(String boxName, T object) async {
    final box = await _openBox<T>(boxName);
    return await box.add(object);
  }

  // READ one par clé
  static Future<T?> get<T>(String boxName, String key) async {
    final box = await _openBox<T>(boxName);
    return box.get(key);
  }

  // READ all (liste)
  static Future<List<T>> getAll<T>(String boxName) async {
    final box = await _openBox<T>(boxName);
    return box.values.cast<T>().toList();
  }

  // DELETE par clé
  static Future<void> delete<T>(String boxName, String key) async {
    final box = await _openBox<T>(boxName);
    await box.delete(key);
  }

  // DELETE all
  static Future<void> clearBox<T>(String boxName) async {
    final box = await _openBox<T>(boxName);
    await box.clear();
  }
}
