import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/index_model_extention.dart';

class HiveService {
  static final Map<String, Box<dynamic>> _boxes = {};

  /// Initialise Hive et enregistre les adaptateurs
  static Future<void> init() async {
    await Hive.initFlutter();
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

  /// Ajoute ou met à jour un objet avec une clé
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

  static Future<void> clear() async {
    for (final box in _boxes.values) {
      await box.clear();
    }
  }

  static Future<void> deleteBox(String boxName) async {
    final box = await _openBox<dynamic>(boxName);
    await box.deleteFromDisk();
  }

  static Future<void> deleteBoxes() async {
    for (final box in _boxes.values) {
      await box.deleteFromDisk();
    }
  }

  static Future<void> deleteAll<T>() async {
    for (final box in _boxes.values) {
      await box.clear();
    }
  }

  static Future<T?> getSync<T>(String boxName, String key) async {
    final box = Hive.box<T>(boxName);
    return box.get(key);
  }

  static Future<void> precachePieceJointe<T>(
    BuildContext c,
    String boxName,
    T pj,
  ) async {
    if (pj is PieceJointe) {
      if (pj.url.isEmpty) return;
      final url = pj.url;
      if (pj.type == 'jpg' ||
          pj.type == 'jpeg' ||
          pj.type == 'png' ||
          pj.type == 'webp') {
        try {
          final box = await _openBox<T>(boxName);
          final image = NetworkImage(pj.url);
          if (c.mounted) {
            await precacheImage(image, c);
          }
          await box.put(pj.id, pj);
          developer.log('[✔] Image précachée: $url');
        } catch (e) {
          developer.log('[❌] Erreur lors de la pré-cache de l\'image: $url');
          developer.log(e.toString());
        }
      } else {
        // 📄 Cas document (PDF, etc.) → on télécharge pour cache en mémoire
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final Uint8List data = response.bodyBytes;
            _cacheMap[url] = data;
            developer.log('[✔] Fichier téléchargé en cache: $url');
          } else {
            developer.log('[⚠] Erreur téléchargement fichier ${pj.nom}');
          }
        } catch (e) {
          developer.log('[⚠] Exception téléchargement fichier: $e');
        }
      }
    } else {
      throw Exception('Type incorrect');
    }
  }

  // Simple cache mémoire
  static final Map<String, Uint8List> _cacheMap = {};

  static Uint8List? getCachedData(String url) => _cacheMap[url];
}
