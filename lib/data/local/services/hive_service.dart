import 'package:hive_flutter/hive_flutter.dart';

import '../adapters/hive_adapters.dart';

class HiveService {
  static final Map<String, Box> _boxes = {};

  /// Initialise Hive et enregistre les adaptateurs
  static Future<void> init() async {
    await Hive.initFlutter();
    await registerHiveAdapters();
  }

  /// Ouvre une box typée et la met en cache
  static Future<Box<T>> _openBox<T>(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      final existingBox = _boxes[boxName];
      if (existingBox is Box<T>) return existingBox;
      throw Exception('Box "$boxName" already opened with a different type.');
    }

    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<T>(boxName);
      _boxes[boxName] = box;
      return box;
    }

    final box = await Hive.openBox<T>(boxName);
    _boxes[boxName] = box;
    return box;
  }

  /// Ajoute un objet avec une clé (PUT = create ou update)
  static Future<void> put<T>(String boxName, String key, T object) async {
    final box = await _openBox<T>(boxName);
    await box.put(key, object);
  }

  /// Ajoute un objet sans clé (clé auto-incrémentée)
  static Future<int> add<T>(String boxName, T object) async {
    final box = await _openBox<T>(boxName);
    return await box.add(object);
  }

  /// Récupère un objet par sa clé
  static Future<T?> get<T>(String boxName, String key) async {
    final box = await _openBox<T>(boxName);
    return box.get(key);
  }

  /// Récupère tous les objets sous forme de liste
  static Future<List<T>> getAll<T>(String boxName) async {
    final box = await _openBox<T>(boxName);
    return box.values.cast<T>().toList();
  }

  /// Supprime un objet par sa clé
  static Future<void> delete<T>(String boxName, String key) async {
    final box = await _openBox<T>(boxName);
    await box.delete(key);
  }

  /// Vide complètement une box
  static Future<void> clearBox<T>(String boxName) async {
    final box = await _openBox<T>(boxName);
    await box.clear();
  }

  /// Vérifie si une clé existe dans une box
  static Future<bool> exists<T>(String boxName, String key) async {
    final box = await _openBox<T>(boxName);
    return box.containsKey(key);
  }

  /// Retourne toutes les clés d'une box
  static Future<List<String>> getKeys<T>(String boxName) async {
    final box = await _openBox<T>(boxName);
    return box.keys.cast<String>().toList();
  }

  /// Retourne la box typée (accès direct si besoin)
  static Future<Box<T>> box<T>(String boxName) async {
    return _openBox<T>(boxName);
  }

  /// Ferme toutes les box ouvertes
  static Future<void> closeAll() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
  }

  /// Ouvre une box typée en toute sécurité, avec cache si déjà ouverte
  Future<Box<T>> getBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }
}
